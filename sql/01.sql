-- 1. show every row
SELECT *
FROM sales;

-- 2. show only German orders
SELECT *
FROM sales
WHERE country = 'Germany';

-- 3. show the highest-value orders
SELECT
    order_id,
    country,
    units_sold * unit_price_eur AS revenue
FROM salesORDER BY revenue DESC;

-- 4. revenue by country
SELECT
    country,
    SUM(units_sold * unit_price_eur) AS revenue
FROM sales
GROUP BY country
ORDER BY revenue DESC;

-- 5. revenue by category
SELECT
    category,
    SUM(units_sold * unit_price_eur) AS revenue
FROM sales
GROUP BY category;

-- 6. show each country and its total revenue from Home-category order, sort from high to low revenue
SELECT
    country,
    SUM(units_sold * unit_price_eur) AS total_revenue
FROM sales
WHERE category = 'Home'
GROUP BY country
ORDER BY total_revenue DESC;