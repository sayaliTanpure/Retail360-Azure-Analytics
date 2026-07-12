CREATE DATABASE retail360;
USE retail360;

CREATE TABLE customers(
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

CREATE TABLE orders(
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME NOT NULL,
    delivery_days INT
);

CREATE TABLE products(
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length FLOAT,
    product_description_length FLOAT,
    product_photos_qty FLOAT,
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT,
    product_volume_cm3 FLOAT,
    is_heavy BOOLEAN,
    is_large BOOLEAN
);

CREATE TABLE order_items(
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
    PRIMARY KEY(order_id, order_item_id)
);

CREATE TABLE payments(
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    installment_category VARCHAR(30),
    is_emi BOOLEAN,
    high_value_payment BOOLEAN,
    PRIMARY KEY(order_id, payment_sequential)
);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY(customer_id)
REFERENCES customers(customer_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_order
FOREIGN KEY(order_id)
REFERENCES orders(order_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_orderitems_product
FOREIGN KEY(product_id)
REFERENCES products(product_id);

ALTER TABLE payments
ADD CONSTRAINT fk_payments_order
FOREIGN KEY(order_id)
REFERENCES orders(order_id);

ALTER TABLE orders
ADD COLUMN purchase_year INT,
ADD COLUMN purchase_month VARCHAR(20),
ADD COLUMN purchase_day INT,
ADD COLUMN purchase_weekday VARCHAR(20),
ADD COLUMN is_weekend BOOLEAN,
ADD COLUMN delivery_delay_days INT,
ADD COLUMN is_delayed BOOLEAN;

ALTER TABLE order_items
ADD COLUMN total_amount FLOAT,
ADD COLUMN freight_percentage FLOAT,
ADD COLUMN is_expensive BOOLEAN;

select * from customers;
select * from orders;
select * from products;
select * from payments;
select * from order_items;

-- Exporting data to gold
-- Customers Summary
SELECT
c.customer_unique_id,
c.customer_city,
c.customer_state,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(pay.payment_value) AS total_spent,
ROUND(AVG(pay.payment_value),2) AS average_order_value,
MIN(o.order_purchase_timestamp) AS first_purchase,
MAX(o.order_purchase_timestamp) AS last_purchase,
ROUND(AVG(o.delivery_days),2) AS average_delivery_days,
SUM(CASE WHEN o.order_status='canceled' THEN 1 ELSE 0 END) AS cancelled_orders,
ROUND(
        SUM(CASE WHEN o.is_delayed=TRUE THEN 1 ELSE 0 END)
        *100.0/
        COUNT(o.order_id),2
    ) AS delay_percentage
FROM customers c
LEFT JOIN orders o
ON c.customer_id=o.customer_id
LEFT JOIN payments pay
ON o.order_id=pay.order_id
GROUP BY
c.customer_unique_id,
c.customer_city,
c.customer_state;

-- Sales Summary
SELECT
purchase_year,
purchase_month,
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(total_amount) AS total_revenue,
ROUND(AVG(total_amount),2) AS average_order_value
FROM orders o
JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY
purchase_year,
purchase_month
ORDER BY
purchase_year,
purchase_month;

-- Delivery Summary
SELECT
customer_state,
COUNT(order_id) AS total_orders,
ROUND(AVG(delivery_days),2) AS average_delivery_days,
ROUND(AVG(delivery_delay_days),2) AS average_delay_days,
SUM(CASE WHEN order_status='delivered' THEN 1 ELSE 0 END) AS delivered_orders,
SUM(CASE WHEN order_status='canceled' THEN 1 ELSE 0 END) AS cancelled_orders,
ROUND(
SUM(CASE WHEN is_delayed=TRUE THEN 1 ELSE 0 END)
*100.0/
COUNT(order_id),2
) AS delay_percentage
FROM orders o
JOIN customers c
ON o.customer_id=c.customer_id
GROUP BY customer_state;

-- payment summary
SELECT
payment_type,
COUNT(*) AS total_transactions,
SUM(payment_value) AS total_revenue,
ROUND(AVG(payment_value),2) AS average_payment,
ROUND(AVG(payment_installments),2) AS average_installments
FROM payments
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- product summary 
SELECT
p.product_category_name,
COUNT(oi.order_item_id) AS total_products_sold,
SUM(oi.price) AS total_revenue,
ROUND(AVG(oi.price),2) AS average_price,
ROUND(AVG(oi.freight_value),2) AS average_freight
FROM products p
JOIN order_items oi
ON p.product_id=oi.product_id
GROUP BY
p.product_category_name
ORDER BY total_revenue DESC;