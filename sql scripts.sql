select *
from superstore_analysis.`superstore data`;

-- Data Cleaning
select count(`Row ID`)
from `superstore data`; -- Row id column is set

select count(distinct `order id`)
from `superstore data`; -- order id is set

select `order date`
from `superstore data`;

-- date columns
update `superstore data`
set `order date` = str_to_date(`order date`, '%m/%d/%Y'),
	`ship date` = str_to_date(`ship date`, '%m/%d/%Y');

alter table `superstore data`
modify column `Order Date` date, 
modify column `ship date` date; -- ship date and order dates are set


-- sales profitability analysis

ALTER TABLE `superstore data`
ADD COLUMN `Profit margin` DECIMAL(10,2) 
AS (ROUND(profit / NULLIF(sales, 0), 2)) VIRTUAL; -- creates a profit margin column


--  regional sales and profit numners
create view `sales performance` as
select 
	region, 
    state,
    round(sum(sales)) `Total Sales`,
	round(sum(profit), 2) Profit,
    round((sum(profit)/ sum(sales)), 2) `Profit margin`,
    count(distinct `order id`) orders,
    sum(Quantity) `units sold`
from `superstore data`
group by region, state;

create view Dates as
select 
	month(`order date`) as `Month`,
    year(`order date`) as `Year`
from `superstore data`;

-- Product profitability analysis
create view `category performance` as
select Category,
		`Sub-Category`,
		round(sum(sales), 2) sales,
		round(sum(Profit), 2) Profit,
        round((sum(profit)/sum(Sales)), 2) `profit margin`,
        count(distinct `order id`) orders,
        sum(Quantity)`units sold`
from `superstore data`
group by Category, `Sub-Category`;

create view `product performance` as
select `product id`,
		round(sum(sales), 2) sales,
		round(sum(Profit), 2) Profit,
        round((sum(profit)/sum(Sales)), 2) `profit margin`,
        count(distinct `order id`) orders,
        sum(Quantity)`units sold`
from `superstore data`
group by `product id`;

-- customer value analysis
create view  `customer segment numbers` as
select 	segment,
        round(sum(profit), 2) Profit,
        round(sum(sales), 2) sales,
        round(sum(profit)/ sum(sales), 2) `Profit margin`,
        count(distinct `order id`) orders,
        sum(Quantity)`units sold`
from `superstore data`
group by Segment;

-- average order intervals
SELECT 
    Segment,
    -- 1. Recency: Days since the most recent order in the whole dataset
    DATEDIFF((SELECT MAX(`Order Date`) FROM `superstore data`), MAX(`Order Date`)) AS Recency_Days,
    
    -- 2. Average Order Period: Total Days spanned / Number of Orders
    ROUND(DATEDIFF(MAX(`Order Date`), MIN(`Order Date`)) / COUNT(`Order ID`), 1) AS Avg_Order_Interval_Days,
    
    -- 3. Volume Check (to contextualize your profit/margin theory)
    COUNT(`Order ID`) AS Total_Orders
FROM `superstore data`
GROUP BY Segment;

-- Average number of days a customer is away before they come with an order
create view `avg days away` as
SELECT 
    Segment,
    -- Average of each individual customer's order frequency
    ROUND(AVG(customer_days_between), 1) AS Avg_Customer_Return_Days,
    COUNT(DISTINCT `Customer ID`) AS Total_Repeat_Customers
FROM (
    SELECT 
        Segment,
        `Customer ID`,
        -- Calculate days between first and last order / gaps
        DATEDIFF(MAX(`Order Date`), MIN(`Order Date`)) / nullif((COUNT(`Order ID`) - 1),0) AS customer_days_between
    FROM `superstore data`
    GROUP BY Segment, `Customer ID`
   HAVING COUNT(`Order ID`) > 1  -- Only look at repeat buyers
) AS customer_metrics
GROUP BY Segment;


		-- Profitablity Drivers 
--  what drives profit more?
--  ship mode?
-- order delivery delays?
-- ship state or region
-- category shipment or state
-- discounts


select `ship mode`,
		 state,
        round(sum(sales), 2) 'Total sales',
        round(((sum(Profit)/ sum(sales)) *100), 2) 'Profit margin'
from `superstore data`
group by `ship mode`, state;


-- shipment mode on different categories

create view `categorical shipment` as 
SELECT 
    Category,
    `Ship Mode`,
    DATEDIFF(`Ship Date`, `Order Date`) AS Days_to_Ship, -- Calculate the gap between order and shipping
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin,
    COUNT(`Order ID`) AS Number_of_Orders
FROM `superstore data`
GROUP BY Category, `Ship Mode`, Days_to_Ship
ORDER BY Category, Days_to_Ship;


-- number of customers that use the different shipmodes

create view `fav ship modes by region` as
select 
	count(`Customer Name`) `number of customers`,
    `Ship Mode`,
    region
from `superstore data`
group by `Ship Mode`, region;


create view `subcategorical shipment` as 
SELECT 
    `Sub-Category`,
    `Ship Mode`,
    DATEDIFF(`Ship Date`, `Order Date`) AS Days_to_Ship, -- Calculate the gap between order and shipping
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin,
    COUNT(`Order ID`) AS Number_of_Orders
FROM `superstore data`
GROUP BY `Sub-Category`, `Ship Mode`, Days_to_Ship
ORDER BY `Sub-Category`, Days_to_Ship;

-- discount effect
# regional discounts 
create view `regional discount VS margin` as
select Region,
		round(avg(Discount),4) `avg discount`,
        round(sum(Sales),2) `Total sales`,
        round(avg(`Profit margin`),4) `Profit margin`
from `superstore data`
group by Region;

create view `state discounts` as 
select state,
		region,
        count(`Order ID`) `number of sales`,
		round(avg(Discount),2) `avg discount`,
        round(sum(Sales),2) `Total sales`,
        round(avg(`Profit margin`),2) `Profit margin`
from `superstore data`
group by state,region;

select Category,
		round(avg(Discount),2) `avg discount`,
        round(sum(Sales),2) `Total sales`,
        round(avg(`Profit margin`),2) `Profit margin`
from `superstore data`
group by Category;

create view `sub category discounts` as
select `Sub-Category`,
		round(avg(Discount),4) `avg discount`,
        round(sum(Sales),2) `Total sales`,
        round(avg(`Profit margin`),4) `Profit margin`
from `superstore data`
group by `Sub-Category`;

select *
from `superstore data`;

