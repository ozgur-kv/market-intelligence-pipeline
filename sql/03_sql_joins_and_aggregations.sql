-- Before answering a join question think about:
-- 1. What is one row in the left table?
-- 2. What is one row in the right table?
-- 3. How often can the join key appear in each table?
-- 4. What will one row represent after the join?
-- 5. Which metrics are safe after the join?

-- Q1. for each table orders, order_items, order_value, return total_rows and distinct_order_ids

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_order_ids
FROM orders;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_order_ids
FROM order_items;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_order_ids
FROM order_value;

-- Q2. INNER JOIN  --> keeps records whose key exists in both tables
-- SELECT
--     ...
-- FROM left_table AS l
-- INNER JOIN right_table AS r
--     ON l.key = r.key
-- write a query joining orders and order_items, return order_id, order_status, order_item_id, price, freight_value, show 10 rows
-- since we are doing an inner join between orders and order items, and we want to see values per order item, one row will rep one item insidean order
SELECT
    o.order_id,
    o.order_status,
    oi.order_item_id,
    oi.price,
    oi.freight_value
FROM orders o
INNER JOIN order_items oi
ON o.order_id = oi.order_id
LIMIT 10;

-- Q3. LEFT JOIN --> keep every row from left table, add matching data from the right table whena available, if no match from right leave NULL for those columns
-- write a join query (orders, order_items) to return total joined rows joined_rows, number of distinct orders distinct_orders, number of matched item rows matched_item_rows
SELECT
    COUNT(*) AS joined_rows, -- count every row produced by join, notice no label in the begging e.g. o.*
    COUNT(DISTINCT o.order_id) AS distinct_orders, -- how many different orders are present
    COUNT(oi.order_item_id) AS matched_item_rows -- how many output rows actually contain item data
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id

-- Q4. Find orders that do not have matching item data.
-- Return: order ID, order status, purchase timestamp
-- Use a left join.
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp
FROM orders o
LEFT JOIN order_items oi
ON o.order_id = oi.order_id
WHERE oi.order_item_id IS NULL;

-- CTE is Common Table Expression
-- Create a named temporary result inside a SQL query, then use it below.
-- WITH temporary_table AS (
--     SELECT
--         ...
-- )
-- SELECT
--     ...
-- FROM temporary_table;

-- Q5. Create a CTE named order_value.
-- Inside the CTE:
-- group order_items by order_id
-- calculate gross_order_value as SUM(price + freight_value)
-- calculate item_count as COUNT(order_item_id)
-- Then return all CTE columns.
WITH order_value AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS gross_order_value,
        COUNT(order_item_id) AS item_count
    FROM order_items
    GROUP BY order_id
)
SELECT * FROM order_value;

-- Q6. Use the same order_value CTE.
-- Left join it to orders.
-- Return: order ID, order status, gross order value, item count
WITH order_value AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS gross_order_value,
        COUNT(order_item_id) AS item_count
    FROM order_items
    GROUP BY order_id
)
SELECT 
    o.order_id,
    o.order_status,
    ov.gross_order_value,
    ov.item_count
FROM orders o
LEFT JOIN order_value ov
ON o.order_id = ov.order_id
LIMIT 10;

-- After the left join, some rows may have:
-- gross_order_value = NULL
-- item_count = NULL
-- Before replacing those values, ask:
-- Does NULL mean zero here,
-- or does it mean the data is unavailable or unmatched?
-- For today’s practice summary, we will treat unmatched item data as zero value.
-- In SQL:
-- COALESCE(value, replacement)
-- means:
-- Use value when it exists.
-- Otherwise use replacement.
-- Example:
-- COALESCE(ov.gross_order_value, 0)
-- means:
-- Use the order value when it exists; otherwise use zero.

-- Q7. Using the order_value CTE:
-- For every order status, calculate:
-- number of distinct orders
-- total gross order value
-- average gross order value
-- Keep statuses even if no item data exists.
-- Use COALESCE, order by total gross order value.
WITH order_value AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS gross_order_value,
        COUNT(order_item_id) AS item_count
    FROM order_items
    GROUP BY order_id
)
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS distinct_orders,
    SUM(COALESCE(ov.gross_order_value, 0)) AS total_gross_order_value,
    AVG(COALESCE(ov.gross_order_value, 0)) AS average_gross_order_value
FROM orders o
LEFT JOIN order_value ov
ON o.order_id = ov.order_id
GROUP BY o.order_status
ORDER BY total_gross_order_value DESC;

-- with AVG(COALESCE(ov.gross_order_value, 0)) - average value will be across all orders, where nulls will be treated as 0
-- with AVG(ov.gross_order_value) - average across order with a known value only

-- Q8 - Using the order_value CTE, calculate monthly metrics for delivered orders.
-- Return:
-- purchase month
-- number of distinct delivered orders
-- total gross order value
-- average gross order value
-- average item count
-- Sort from oldest to newest month.
WITH order_value AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS gross_order_value,
        COUNT(order_item_id) AS item_count
    FROM order_items
    GROUP BY order_id
)
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS purchase_month,
    COUNT(DISTINCT o.order_id) AS distinct_orders,
    SUM(ov.gross_order_value) AS total_gross_order_value,
    AVG(ov.gross_order_value) AS average_gross_order_value,
    AVG(ov.item_count) AS average_item_count
FROM orders o
INNER JOIN order_value ov
ON o.order_id = ov.order_id
WHERE o.order_status = 'delivered'
GROUP BY purchase_month
ORDER BY purchase_month;