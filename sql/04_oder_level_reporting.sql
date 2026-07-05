-- 1. Write a query that:
-- Creates a CTE named order_value.
-- Aggregates order_items to one row per order.
-- Calculates:
-- gross_order_value = SUM(price + freight_value)
-- item_count = COUNT(order_item_id)
-- Left joins order_value to orders.
-- Filters to delivered orders.
-- Groups by purchase month.
-- Returns:
-- purchase_month
-- delivered_orders
-- total_gross_order_value
-- average_gross_order_value
-- average_item_count
-- delivered_orders_missing_item_data

WITH order_value AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS gross_order_value,
        COUNT(order_item_id) AS item_count
    FROM order_items
    GROUP BY order_id
)
SELECT
    CAST(DATE_TRUNC('month',o.order_purchase_timestamp) AS DATE) AS purchase_month,
    COUNT(o.order_id) AS delivered_orders,
    SUM(ov.gross_order_value) AS total_gross_order_value,
    AVG(ov.gross_order_value) AS average_gross_order_value,
    AVG(ov.item_count) AS average_item_count
    SUM(
        CASE
            WHEN ov.order_id IS NULL THEN 1
            ELSE 0
        END
    ) AS delivered_orders_missing_item_data
FROM orders o
LEFT JOIN order_value ov
ON o.order_id = ov.order_id
WHERE o.order_status = 'delivered'
GROUP BY purchase_month
ORDER BY purchase_month;