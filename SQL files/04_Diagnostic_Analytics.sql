-- 1) Why do some states generate more revenue than others?
-- States generating higher evenue
SELECT c.customer_state, SUM(p.payment_value) AS total_revenue
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN payments p
ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- In which city total_customers are higher
SELECT customer_state, COUNT(customer_unique_id) AS total_customer
FROM customers
GROUP BY customer_state
ORDER BY total_customer DESC;

-- Which state has more orders
SELECT c.customer_state, COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

-- CONCLUSION - SP state has generated more revenue becuase it has more customers and more orders than others

-- 2) Which product categories have the highest delivery delays?
SELECT p.product_category_name, ROUND(AVG(o.delivery_delay_days),2) AS avg_delivery_delay_days
FROM products p 
INNER JOIN order_items oi
ON p.product_id = oi.product_id
INNER JOIN orders o
ON oi.order_id = o.order_id
GROUP BY p.product_category_name
ORDER BY avg_delivery_delay_days DESC;

-- Which category has the largest number of delayed deliveries
SELECT p.product_category_name, COUNT(*) AS delayed_orders
FROM products p
INNER JOIN order_items oi
ON p.product_id = oi.product_id
INNER JOIN orders o
ON oi.order_id = o.order_id
WHERE o.is_delayed = 1
GROUP BY p.product_category_name
ORDER BY delayed_orders DESC;

-- 3) Which sellers have the highest cancellation rates?
SELECT oi.seller_id, 
COUNT(DISTINCT CASE WHEN o.order_status = 'canceled' THEN o.order_id END) AS cancelled_orders
FROM order_items oi
INNER JOIN orders o
ON oi.order_id = o.order_id
GROUP BY oi.seller_id
ORDER BY cancelled_orders DESC;

-- Why do some cities have lower average order values?
-- Average order value by city
SELECT c.customer_city, ROUND(AVG(p.payment_value),2) avg_order_value
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN payments p
ON o.order_id=p.order_id
GROUP BY c.customer_city
ORDER BY avg_order_value DESC;

SELECT ROUND(AVG(oi.price),2) avg_product_price
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY c.customer_city
ORDER BY avg_product_price;
