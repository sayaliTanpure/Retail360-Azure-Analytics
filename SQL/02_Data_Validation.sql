-- 1) Total records in each table

SELECT 'customers' AS Table_Name, COUNT(*) AS Total_Records
FROM customers
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders
UNION ALL
SELECT 'products', COUNT(*)
FROM products
UNION ALL
SELECT 'order_items', COUNT(*)
FROM order_items
UNION ALL
SELECT 'payments', COUNT(*)
FROM payments;

-- 2)Check duplicate primary keys

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT order_id,order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT order_id, payment_sequential,COUNT(*)
FROM payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- 4) Table Statistics
SELECT
MIN(payment_value),
MAX(payment_value),
AVG(payment_value)
FROM payments;

SELECT
MIN(price),
MAX(price),
AVG(price)
FROM order_items;

