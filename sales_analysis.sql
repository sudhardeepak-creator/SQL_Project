-- =====================================================================
-- Lite SQL Project: Sales Analysis  (MySQL 8.0+)
-- One file: setup -> core functions -> joins -> CTE -> window functions
-- =====================================================================
DROP DATABASE IF EXISTS sales_lite;
CREATE DATABASE sales_lite;
USE sales_lite;

-- ---------- 1. SETUP ----------
CREATE TABLE customers (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL,
    email       VARCHAR(80),
    city        VARCHAR(40),
    signup_date DATE
);
CREATE TABLE products (
    id       INT PRIMARY KEY AUTO_INCREMENT,
    name     VARCHAR(50) NOT NULL,
    category VARCHAR(30),
    price    DECIMAL(10,2) NOT NULL
);
CREATE TABLE orders (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id  INT NOT NULL,
    qty         INT NOT NULL,
    order_date  DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (product_id)  REFERENCES products(id)
);

INSERT INTO customers (name, email, city, signup_date) VALUES
('Arun Kumar',  'arun@mail.com',  'Chennai',   '2024-01-15'),
('Priya Sharma','priya@mail.com', 'Mumbai',    '2024-03-20'),
('John Smith',  NULL,             'New York',  '2024-05-05'),
('Meena Iyer',  'meena@mail.com', 'Chennai',   '2024-08-11'),
('Rahul Verma', 'rahul@mail.com', 'Delhi',     '2025-01-09');   -- never orders

INSERT INTO products (name, category, price) VALUES
('Headphones',  'Electronics', 2999),
('Smartphone',  'Electronics', 24999),
('SQL Book',    'Books',       599),
('T-Shirt',     'Clothing',    499),
('Yoga Mat',    'Sports',      999);

INSERT INTO orders (customer_id, product_id, qty, order_date) VALUES
(1,1,1,'2025-01-10'), (1,3,2,'2025-02-14'), (2,2,1,'2025-02-20'),
(2,4,3,'2025-03-05'), (3,5,2,'2025-03-18'), (4,1,2,'2025-04-02'),
(4,2,1,'2025-04-25'), (1,2,1,'2025-05-09'), (3,3,1,'2025-06-01');

CREATE VIEW order_details AS
SELECT o.id AS order_id, c.name AS customer, c.city, p.name AS product, p.category,
       o.qty, p.price, o.qty * p.price AS total, o.order_date
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN products  p ON p.id = o.product_id;

-- ---------- 2. AGGREGATES ----------
SELECT COUNT(*) AS orders, SUM(total) AS revenue, ROUND(AVG(total),2) AS avg_order,
       MIN(total) AS smallest, MAX(total) AS largest
FROM order_details;

SELECT category, SUM(total) AS revenue, COUNT(*) AS orders
FROM order_details
GROUP BY category
HAVING SUM(total) > 3000
ORDER BY revenue DESC;

-- ---------- 3. STRING FUNCTIONS ----------
SELECT UPPER(name)                              AS name_upper,
       SUBSTRING_INDEX(name, ' ', 1)            AS first_name,
       LENGTH(name)                             AS name_length,
       COALESCE(email, 'no email')              AS email,
       CONCAT(LEFT(city, 3), '-', LPAD(id, 3, '0')) AS customer_code
FROM customers;

-- ---------- 4. DATE FUNCTIONS ----------
SELECT order_id, order_date,
       YEAR(order_date)                AS yr,
       MONTHNAME(order_date)           AS month_name,
       DATE_FORMAT(order_date,'%d %b %Y') AS pretty_date,
       DATEDIFF(CURDATE(), order_date) AS days_ago
FROM order_details;

SELECT DATE_FORMAT(order_date,'%Y-%m') AS month, SUM(total) AS revenue
FROM order_details
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
ORDER BY month;

-- ---------- 5. NUMERIC & CONDITIONAL ----------
SELECT name, price,
       ROUND(price * 0.18, 2) AS gst_18,
       CEIL(price / 1000)     AS price_in_thousands,
       CASE WHEN price < 1000  THEN 'Budget'
            WHEN price < 10000 THEN 'Mid'
            ELSE 'Premium' END AS price_band
FROM products;

-- ---------- 6. JOINS ----------
-- Customers who never ordered (LEFT JOIN + IS NULL)
SELECT c.name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE o.id IS NULL;

-- Orders per customer, including zero
SELECT c.name, COUNT(o.id) AS orders
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.name;

-- ---------- 7. SUBQUERY & CTE ----------
-- Products priced above average
SELECT name, price FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Customers who spent more than the average customer
WITH spend AS (
    SELECT customer, SUM(total) AS total_spent
    FROM order_details
    GROUP BY customer
)
SELECT customer, total_spent
FROM spend
WHERE total_spent > (SELECT AVG(total_spent) FROM spend)
ORDER BY total_spent DESC;

-- ---------- 8. WINDOW FUNCTIONS ----------
-- Rank customers by spend
SELECT customer, SUM(total) AS total_spent,
       RANK() OVER (ORDER BY SUM(total) DESC) AS spend_rank
FROM order_details
GROUP BY customer;

-- Running total of revenue
SELECT order_id, order_date, total,
       SUM(total) OVER (ORDER BY order_date, order_id) AS running_total
FROM order_details;

-- Previous order amount per customer (LAG)
SELECT customer, order_date, total,
       LAG(total) OVER (PARTITION BY customer ORDER BY order_date) AS prev_order_total
FROM order_details;

-- Top product in each category
SELECT category, product, revenue FROM (
    SELECT category, product, SUM(total) AS revenue,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(total) DESC) AS rn
    FROM order_details
    GROUP BY category, product
) t
WHERE rn = 1;
