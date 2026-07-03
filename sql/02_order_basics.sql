-- Table: orders
-- Columns:
-- order_id
-- customer_id
-- order_date
-- category
-- quantity
-- unit_price
-- discount
-- revenue

-- Question 1
-- Which category generates the highest total revenue?

SELECT
    category,
    SUM(revenue) AS total_revenue
FROM orders
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 1;

-- Question 2
-- How many rows are in the orders table? 
-- Also count how many distinct order IDs exist.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders
FROM orders;

-- Question 3 
-- Calculate these overall business metrics: 
-- - total revenue 
-- - total quantity sold 
-- - average revenue per row 
-- - maximum revenue for one row

SELECT
    SUM(revenue) AS total_revenue,
    SUM(quantity) AS total_quantity,
    AVG(revenue) AS average_revenue,
    MAX(revenue) AS max_revenue
FROM orders;

-- Question 4
-- For each category, calculate:
-- - number of distinct orders
-- - total quantity sold
-- - total revenue
-- - average revenue per row
-- Sort by total revenue from highest to lowest.

SELECT
    COUNT(DISTINCT order_id) AS distinct_orders,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue,
    AVG(revenue) AS average_revenue
FROM orders
GROUP BY category
ORDER BY total_revenue DESC;

-- Question 5
-- Find the top 5 customers by total spending.
-- Return:
-- - customer_id
-- - number of distinct orders
-- - total revenue
-- Sort from highest to lowest total revenue.

SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS distinct_orders,
    SUM(revenue) AS total_revenue
FROM orders
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 5;

-- Question 6
-- Find categories that have generated total revenue above 1,000.
-- Return:
-- - category
-- - total revenue
-- Sort from highest to lowest total revenue.
-- Important:
-- This requires filtering AFTER aggregation.

SELECT
    category,
    SUM(revenue) AS total_revenue
FROM orders
GROUP BY category
HAVING SUM(revenue) > 1000
ORDER BY total_revenue DESC; 

-- Question 7
-- Show orders where:
-- - category is 'Electronics'
-- - revenue is greater than 100
-- Return:
-- - order_id
-- - customer_id
-- - quantity
-- - unit_price
-- - discount
-- - revenue
-- Sort from highest to lowest revenue.

SELECT 
    order_id,
    customer_id,
    quantity,
    unit_price,
    discount,
    revenue
FROM orders
WHERE category = 'Electronics' AND revenue > 100
ORDER BY revenue DESC;

-- Question 8
-- Calculate the average discount for each category.
-- Return:
-- - category
-- - average_discount
-- - total_revenue
-- Sort by average discount from highest to lowest.

SELECT
    category,
    AVG(discount) AS average_discount,
    SUM(revenue) AS total_revenue
FROM orders
GROUP BY category
ORDER BY average_discount DESC;

-- Question 9
-- Find the date with the highest total revenue.
-- Return:
-- - order_date
-- - total revenue on that date
-- Hint:
-- First aggregate revenue by date, then sort descending,
-- then keep only the top result.

SELECT
    order_date,
    SUM(revenue) AS total_revenue
FROM orders
GROUP BY order_date
ORDER BY total_revenue DESC
LIMIT 1;

-- Question 10
-- For each customer, calculate:
-- - number of distinct orders
-- - total revenue
-- - average revenue per order row
-- Only keep customers who have placed more than one distinct order.
-- Sort from highest to lowest total revenue.

SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS distinct_orders,
    SUM(revenue) AS total_revenue,
    AVG(revenue) AS average_revenue
FROM orders
GROUP BY customer_id
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY total_revenue DESC;
