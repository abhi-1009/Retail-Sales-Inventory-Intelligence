CREATE DATABASE retail_analysis;

USE retail_analysis;

CREATE TABLE brands (brand_id INT PRIMARY KEY, brand_name VARCHAR(50));

CREATE TABLE categories (category_id INT PRIMARY KEY, category_name VARCHAR(50));

CREATE TABLE stores (store_id INT PRIMARY KEY, store_name VARCHAR(100),phone VARCHAR(20), email VARCHAR(100),
	street VARCHAR(200), city VARCHAR(50),state CHAR(2), zip_code VARCHAR(10));

CREATE TABLE customers (customer_id INT PRIMARY KEY, first_name VARCHAR(50), last_name VARCHAR(50),
	phone VARCHAR(20), email VARCHAR(100), street VARCHAR(200),city VARCHAR(50), state CHAR(2), zip_code VARCHAR(10));

CREATE TABLE staffs (staff_id INT PRIMARY KEY, first_name VARCHAR(50), last_name VARCHAR(50),email VARCHAR(100), 
	phone VARCHAR(20), active TINYINT,store_id INT, manager_id INT,FOREIGN KEY (store_id) REFERENCES stores(store_id));
alter table staffs modify column manager_id INT NULL;
INSERT INTO staffs (staff_id, first_name, last_name, email, phone, active, store_id, manager_id)
VALUES (1, 'Fabiola', 'Jackson', 'fabiola.jackson@bikes.shop', '(831) 555-5554', 1, 1, NULL);

CREATE TABLE products (product_id INT PRIMARY KEY, product_name VARCHAR(200),brand_id INT, category_id INT, 
	model_year INT, list_price DECIMAL(10,2),FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
	FOREIGN KEY (category_id) REFERENCES categories(category_id));
ALTER TABLE products ADD CONSTRAINT fk_products_brands FOREIGN KEY (brand_id) REFERENCES brands(brand_id);
ALTER TABLE products ADD CONSTRAINT fk_products_categories FOREIGN KEY (category_id) REFERENCES categories(category_id);
  
CREATE TABLE orders (order_id INT PRIMARY KEY, customer_id INT, order_status VARCHAR(20), order_date DATE,
    required_date DATE, shipped_date DATE NULL, store_id INT, staff_id INT);
INSERT INTO orders_final
SELECT order_id, customer_id, order_status,STR_TO_DATE(order_date, '%Y-%m-%d'),STR_TO_DATE(required_date, '%Y-%m-%d'),
    CASE
        WHEN shipped_date = ''
             OR shipped_date IS NULL
        THEN NULL
        ELSE STR_TO_DATE(shipped_date, '%Y-%m-%d')
    END,
    store_id, staff_id
FROM orders;
ALTER TABLE orders_final ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
ALTER TABLE orders_final ADD CONSTRAINT fk_store FOREIGN KEY (store_id) REFERENCES stores(store_id);
ALTER TABLE orders_final ADD CONSTRAINT fk_staff FOREIGN KEY (staff_id) REFERENCES staffs(staff_id);

RENAME TABLE orders_final TO orders;

CREATE TABLE order_items (order_id INT, item_id INT, product_id INT, quantity INT, list_price DECIMAL(10,2), 
	discount DECIMAL(4,2),revenue decimal(10,2), discount_amount decimal(10,2));
ALTER TABLE order_items ADD PRIMARY KEY (order_id, item_id);  
ALTER TABLE order_items ADD CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id);
ALTER TABLE order_items ADD CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(product_id); 

CREATE TABLE stocks (store_id INT, product_id INT, quantity INT);
ALTER TABLE stocks ADD PRIMARY KEY (store_id, product_id);
ALTER TABLE stocks ADD CONSTRAINT fk_stocks_store FOREIGN KEY (store_id) REFERENCES stores(store_id);
ALTER TABLE stocks ADD CONSTRAINT fk_stocks_product FOREIGN KEY (product_id) REFERENCES products(product_id);

SELECT DISTINCT product_id FROM stocks WHERE product_id NOT IN (SELECT product_id FROM products);
SELECT DISTINCT product_id FROM order_items WHERE product_id NOT IN (SELECT product_id FROM products)ORDER BY product_id;
SELECT DISTINCT store_id FROM stocks WHERE store_id NOT IN (SELECT store_id FROM stores);
SELECT store_id, product_id, COUNT(*) FROM stocks GROUP BY store_id, product_id HAVING COUNT(*) > 1;
DELETE FROM stocks WHERE product_id NOT IN (SELECT product_id FROM products);
SELECT order_id, item_id, COUNT(*) FROM order_items GROUP BY order_id, item_id HAVING COUNT(*) > 1;
SELECT DISTINCT order_id FROM order_items WHERE order_id NOT IN (SELECT order_id FROM orders);
DELETE FROM order_items WHERE product_id NOT IN (SELECT product_id FROM products);
DELETE FROM order_items WHERE product_id IN (SELECT product_id FROM (SELECT DISTINCT product_id FROM order_items
        WHERE product_id NOT IN (SELECT product_id FROM products)) AS temp);

SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) AS orphan_orders FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
SELECT COUNT(*) AS orphan_items FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
SELECT COUNT(*) AS orphan_products FROM order_items oi LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
SELECT COUNT(*) AS bad_store  FROM orders WHERE store_id NOT IN (SELECT store_id FROM stores);
SELECT COUNT(*) AS bad_staff  FROM orders WHERE staff_id NOT IN (SELECT staff_id FROM staffs);

-- Total sales summary
SELECT
  COUNT(DISTINCT o.order_id) AS total_orders,
  COUNT(DISTINCT o.customer_id) AS total_customers,
  SUM(oi.quantity) AS total_units_sold,
  ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2)  AS net_revenue,
  ROUND(SUM(oi.quantity * oi.list_price * oi.discount), 2)  AS total_discounts
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;

-- Top 10 best-selling products by revenue
SELECT
  p.product_name, b.brand_name, c.category_name,
  SUM(oi.quantity) AS units_sold,
  ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2) AS revenue
FROM order_items oi
JOIN products p   ON oi.product_id = p.product_id
JOIN brands b     ON p.brand_id    = b.brand_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.product_id, p.product_name, b.brand_name, c.category_name ORDER BY revenue DESC LIMIT 10;

-- Revenue by store + state
SELECT
  st.store_name, st.state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2) AS revenue,
  ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount))
    / SUM(SUM(oi.quantity * oi.list_price * (1-oi.discount))) OVER() * 100, 1) AS revenue_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN stores st      ON o.store_id = st.store_id
GROUP BY st.store_id, st.store_name, st.state ORDER BY revenue DESC;

-- Revenue by brand + category
SELECT
  c.category_name,
  b.brand_name,
  ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2) AS revenue,
  ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount))
    / SUM(SUM(oi.quantity * oi.list_price * (1-oi.discount))) OVER() * 100, 1) AS pct
FROM order_items oi
JOIN products p   ON oi.product_id = p.product_id
JOIN brands b     ON p.brand_id    = b.brand_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name, b.brand_id, b.brand_name ORDER BY revenue DESC LIMIT 5;

-- Staff performance by revenue handled
SELECT
  CONCAT(s.first_name,' ',s.last_name) AS staff_name,
  st.store_name, COUNT(DISTINCT o.order_id) AS orders_handled,
  ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2) AS revenue_handled
FROM orders o
JOIN staffs s      ON o.staff_id  = s.staff_id
JOIN stores st     ON o.store_id  = st.store_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY s.staff_id, staff_name, st.store_name ORDER BY revenue_handled DESC;

-- Inventory analysis: stock levels + alerts
SELECT st.store_name, p.product_name, b.brand_name, c.category_name, sk.quantity,
  CASE
    WHEN sk.quantity = 0  THEN 'OUT OF STOCK'
    WHEN sk.quantity < 5  THEN 'LOW STOCK'
    WHEN sk.quantity < 20 THEN 'MEDIUM'
    ELSE 'SUFFICIENT'
  END AS stock_status
FROM stocks sk
JOIN stores st     ON sk.store_id   = st.store_id
JOIN products p    ON sk.product_id = p.product_id
JOIN brands b      ON p.brand_id    = b.brand_id
JOIN categories c  ON p.category_id = c.category_id ORDER BY sk.quantity ASC LIMIT 5;

-- Year-over-year and monthly trends
SELECT YEAR(o.order_date) AS yr, MONTH(o.order_date) AS mo,
  DATE_FORMAT(o.order_date,'%Y-%m') AS period, COUNT(DISTINCT o.order_id) AS orders,
  ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id GROUP BY yr, mo, period ORDER BY yr, mo;

-- Year totals
SELECT YEAR(order_date) AS yr, ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2) AS revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id GROUP BY yr;

-- Customer analysis: loyalty + lifetime value
SELECT CONCAT(c.first_name,' ',c.last_name) AS customer_name, c.state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2) AS lifetime_value
FROM customers c JOIN orders o ON c.customer_id = o.customer_id JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, customer_name, c.state ORDER BY lifetime_value DESC LIMIT 10;

SELECT 
  CONCAT(c.first_name,' ',c.last_name) AS customer_name, c.state,
  COUNT(o.order_id) AS total_orders, ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, customer_name, c.state ORDER BY lifetime_value DESC LIMIT 10;

-- Repeat buyer breakdown
SELECT order_count, COUNT(*) AS customers, ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),1) AS pct
FROM (SELECT customer_id, COUNT(DISTINCT order_id) AS order_count FROM orders GROUP BY customer_id) t
GROUP BY order_count ORDER BY order_count;

-- SQL Views for Power BI connection
-- vw_customer_ltv
CREATE OR REPLACE VIEW vw_customer_ltv AS
SELECT c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
  c.state, c.city, COUNT(DISTINCT o.order_id) AS order_count,
  ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2) AS lifetime_value,
  MIN(o.order_date) AS first_order_date, MAX(o.order_date) AS last_order_date
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, customer_name, c.state, c.city;

-- vw_staff_performance
CREATE OR REPLACE VIEW vw_staff_performance AS
SELECT CONCAT(sf.first_name,' ',sf.last_name) AS staff_name,  st.store_name,
  COUNT(DISTINCT o.order_id) AS orders_handled, 
  ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2) AS revenue_handled
FROM staffs sf JOIN orders o ON sf.staff_id = o.staff_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN stores st ON sf.store_id = st.store_id GROUP BY sf.staff_id, staff_name, st.store_name;

-- vw_stock_summary
CREATE OR REPLACE VIEW vw_stock_summary AS
SELECT st.store_name, st.state, b.brand_name, cat.category_name, p.product_name, sk.quantity AS stock_qty,
  CASE
    WHEN sk.quantity = 0  THEN 'Out of Stock'
    WHEN sk.quantity < 5  THEN 'Low Stock'
    WHEN sk.quantity < 20 THEN 'Medium'
    ELSE 'Sufficient'
  END AS stock_status
FROM stocks sk JOIN stores st ON sk.store_id = st.store_id
JOIN products p ON sk.product_id = p.product_id JOIN brands b ON p.brand_id = b.brand_id
JOIN categories cat ON p.category_id = cat.category_id;

-- vw_sales_master
CREATE OR REPLACE VIEW vw_sales_master AS SELECT o.order_id, o.order_date, o.required_date, o.shipped_date,
  CASE o.order_status
    WHEN 1 THEN 'Pending' WHEN 2 THEN 'Processing'
    WHEN 3 THEN 'Rejected' WHEN 4 THEN 'Completed'
  END AS order_status,
  CASE
    WHEN o.shipped_date > o.required_date THEN 'Late'
    WHEN o.shipped_date IS NULL THEN 'Not Shipped'
    ELSE 'On Time'
  END AS shipment_status,
  CONCAT(c.first_name,' ',c.last_name) AS customer_name, c.state AS cust_state, c.city AS cust_city,
  st.store_name, st.state AS store_state, CONCAT(sf.first_name,' ',sf.last_name) AS staff_name,
  p.product_name, p.model_year, b.brand_name, cat.category_name, oi.quantity, oi.list_price, oi.discount,
  ROUND(oi.quantity * oi.list_price * (1-oi.discount), 2) AS net_revenue,
  ROUND(oi.quantity * oi.list_price * oi.discount, 2)     AS discount_amount,
  ROUND(oi.quantity * oi.list_price, 2)                   AS gross_revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id JOIN customers c ON o.customer_id = c.customer_id
JOIN stores st ON o.store_id = st.store_id JOIN staffs sf ON o.staff_id = sf.staff_id
JOIN products p ON oi.product_id = p.product_id JOIN brands b ON p.brand_id = b.brand_id
JOIN categories cat ON p.category_id = cat.category_id;

CREATE OR REPLACE VIEW vw_sales_master AS
SELECT o.order_id, o.order_date, o.required_date, o.shipped_date, 
CASE o.order_status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Rejected'
        WHEN 4 THEN 'Completed'
END AS order_status,
CASE
        WHEN o.shipped_date > o.required_date THEN 'Late'
        WHEN o.shipped_date IS NULL THEN 'Not Shipped'
        ELSE 'On Time'
END AS shipment_status,
c.customer_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name, c.state AS cust_state,
c.city AS cust_city, st.store_name, st.state AS store_state, CONCAT(sf.first_name,' ',sf.last_name) AS staff_name,
p.product_id, p.product_name, p.model_year, b.brand_name, cat.category_name, oi.quantity, oi.list_price,
oi.discount, ROUND(oi.quantity * oi.list_price * (1-oi.discount),2) AS net_revenue,
ROUND(oi.quantity * oi.list_price * oi.discount, 2) AS discount_amount,
ROUND(oi.quantity * oi.list_price,2) AS gross_revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c ON o.customer_id = c.customer_id
JOIN stores st ON o.store_id = st.store_id
JOIN staffs sf ON o.staff_id = sf.staff_id
JOIN products p ON oi.product_id = p.product_id
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories cat ON p.category_id = cat.category_id;