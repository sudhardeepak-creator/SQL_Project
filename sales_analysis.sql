-- =====================================================================
-- SQL Project: Sales Analysis (Lite+)   |   MySQL 8.0+
-- One file, run top to bottom.
--  1 Setup            5 Numeric & conditional    9  Subqueries & CTEs
--  2 Aggregates       6 NULL handling & casting  10 Set operations
--  3 String functions 7 Joins                    11 Window functions
--  4 Date functions   8 Pattern matching         12 Function, procedure, trigger, transaction
-- =====================================================================

-- ---------- 1. SETUP ----------
DROP DATABASE IF EXISTS sales_lite;
CREATE DATABASE sales_lite;
USE sales_lite;

CREATE TABLE customers (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL,
    email       VARCHAR(80),
    phone       VARCHAR(15),
    city        VARCHAR(40),
    signup_date DATE
);
CREATE TABLE products (
    id       INT PRIMARY KEY AUTO_INCREMENT,
    name     VARCHAR(50) NOT NULL,
    category VARCHAR(30),
    price    DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock    INT NOT NULL DEFAULT 0
);
CREATE TABLE orders (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id  INT NOT NULL,
    qty         INT NOT NULL,
    order_date  DATE NOT NULL,
    status      VARCHAR(15) NOT NULL DEFAULT 'Delivered',
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (product_id)  REFERENCES products(id)
);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date     ON orders(order_date);

INSERT INTO customers (name, email, phone, city, signup_date) VALUES
('Arun Kumar',   'arun@mail.com',  '9876500001', 'Chennai',  '2024-01-15'),
('Priya Sharma', 'priya@mail.com', '9876500002', 'Mumbai',   '2024-03-20'),
('John Smith',   NULL,             NULL,         'New York', '2024-05-05'),
('Meena Iyer',   'meena@mail.com', '9876500004', 'Chennai',  '2024-08-11'),
('Rahul Verma',  'rahul@mail.com', '9876500005', 'Delhi',    '2025-01-09');   -- never orders

INSERT INTO products (name, category, price, stock) VALUES
('Headphones', 'Electronics', 2999,  50),
('Smartphone', 'Electronics', 24999, 20),
('SQL Book',   'Books',       599,   100),
('T-Shirt',    'Clothing',    499,   200),
('Yoga Mat',   'Sports',      999,   0),
('Football',   'Sports',      799,   60);   -- never sold

INSERT INTO orders (customer_id, product_id, qty, order_date, status) VALUES
(1,1,1,'2025-01-10','Delivered'), (1,3,2,'2025-02-14','Delivered'),
(2,2,1,'2025-02-20','Delivered'), (2,4,3,'2025-03-05','Delivered'),
(3,5,2,'2025-03-18','Cancelled'),(4,1,2,'2025-04-02','Delivered'),
(4,2,1,'2025-04-25','Delivered'),(1,2,1,'2025-05-09','Delivered'),
(3,3,1,'2025-06-01','Delivered'),(2,1,1,'2025-06-15','Shipped');

CREATE VIEW order_details AS
SELECT o.id AS order_id, c.id AS customer_id, c.name AS customer, c.city,
       p.name AS product, p.category, o.qty, p.price,
       o.qty * p.price AS total, o.order_date, o.status
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN products  p ON p.id = o.product_id;

-- ---------- 2. AGGREGATES ----------
-- Overall KPIs (COUNT, SUM, AVG, MIN, MAX)
SELECT COUNT(*) AS orders, COUNT(DISTINCT customer_id) AS buyers,
       SUM(total) AS revenue, ROUND(AVG(total),2) AS avg_order,
       MIN(total) AS smallest, MAX(total) AS largest
FROM order_details
WHERE status <> 'Cancelled';

-- COUNT(*) vs COUNT(column): NULLs are ignored by COUNT(column)
SELECT COUNT(*) AS customers, COUNT(email) AS with_email FROM customers;

-- GROUP BY + HAVING
SELECT category, SUM(total) AS revenue, COUNT(*) AS orders
FROM order_details
WHERE status <> 'Cancelled'
GROUP BY category
HAVING SUM(total) > 3000
ORDER BY revenue DESC;

-- GROUP_CONCAT: products bought by each customer
SELECT customer, GROUP_CONCAT(DISTINCT product ORDER BY product SEPARATOR ', ') AS products_bought
FROM order_details
GROUP BY customer;

-- ROLLUP: subtotals and grand total
SELECT COALESCE(category, 'ALL') AS category, COALESCE(product, 'ALL') AS product, SUM(total) AS revenue
FROM order_details
WHERE status <> 'Cancelled'
GROUP BY category, product WITH ROLLUP;

-- Conditional aggregation (pivot style)
SELECT SUM(status = 'Delivered') AS delivered,
       SUM(status = 'Shipped')   AS shipped,
       SUM(status = 'Cancelled') AS cancelled
FROM orders;

-- ---------- 3. STRING FUNCTIONS ----------
SELECT UPPER(name) AS name_upper,
       LOWER(city) AS city_lower,
       LENGTH(name) AS name_length,
       SUBSTRING_INDEX(name, ' ', 1)  AS first_name,
       SUBSTRING_INDEX(name, ' ', -1) AS last_name,
       CONCAT_WS(' - ', name, city)   AS label,
       CONCAT(LEFT(city, 3), '-', LPAD(id, 3, '0')) AS customer_code,
       COALESCE(CONCAT('XXXXXX', RIGHT(phone, 4)), 'No phone') AS masked_phone,
       SUBSTRING_INDEX(email, '@', -1) AS email_domain
FROM customers;

SELECT TRIM('   hello   ') AS trimmed,
       REPLACE('SQL is hard', 'hard', 'fun') AS replaced,
       REVERSE('SQL') AS reversed,
       LOCATE('@', 'arun@mail.com') AS at_position,
       REPEAT('*', 5) AS stars,
       FORMAT(1234567.891, 2) AS formatted_number;

-- ---------- 4. DATE FUNCTIONS ----------
SELECT order_id, order_date,
       YEAR(order_date)                   AS yr,
       QUARTER(order_date)                AS qtr,
       MONTHNAME(order_date)              AS month_name,
       DAYNAME(order_date)                AS weekday,
       DATE_FORMAT(order_date, '%d %b %Y') AS pretty_date,
       DATE_ADD(order_date, INTERVAL 7 DAY) AS return_deadline,
       LAST_DAY(order_date)               AS month_end,
       DATEDIFF(CURDATE(), order_date)    AS days_ago
FROM order_details;

-- Customer tenure
SELECT name, signup_date,
       TIMESTAMPDIFF(MONTH, signup_date, CURDATE()) AS months_as_customer
FROM customers;

-- Monthly revenue trend
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(total) AS revenue
FROM order_details
WHERE status <> 'Cancelled'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Parse text into a date
SELECT STR_TO_DATE('15-08-2025', '%d-%m-%Y') AS parsed_date;

-- ---------- 5. NUMERIC & CONDITIONAL ----------
SELECT name, price,
       ROUND(price * 0.18, 2)  AS gst_18,
       CEIL(price / 1000)      AS price_in_thousands_up,
       FLOOR(price / 1000)     AS price_in_thousands_down,
       MOD(price, 100)         AS remainder_100,
       POW(2, 3)               AS power_example,
       CASE WHEN price < 1000  THEN 'Budget'
            WHEN price < 10000 THEN 'Mid'
            ELSE 'Premium' END AS price_band,
       IF(stock = 0, 'OUT OF STOCK', 'Available') AS availability,
       GREATEST(price, 1000)   AS at_least_1000
FROM products;

-- ---------- 6. NULL HANDLING & CASTING ----------
SELECT name,
       IFNULL(email, 'not provided')        AS email_ifnull,
       COALESCE(email, phone, 'no contact') AS best_contact,
       NULLIF(city, 'Chennai')              AS city_or_null
FROM customers;

-- Safe division (avoids divide-by-zero)
SELECT name, ROUND(price / NULLIF(stock, 0), 2) AS price_per_unit_in_stock FROM products;

SELECT CAST(price AS SIGNED) AS price_int, CAST(price AS CHAR) AS price_text,
       CAST('2025-12-31' AS DATE) AS text_to_date
FROM products LIMIT 3;

-- ---------- 7. JOINS ----------
-- INNER JOIN
SELECT o.id, c.name, p.name AS product, o.qty
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN products  p ON p.id = o.product_id;

-- LEFT JOIN + IS NULL: customers who never ordered
SELECT c.name FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE o.id IS NULL;

-- RIGHT JOIN: products never sold
SELECT p.name FROM orders o
RIGHT JOIN products p ON p.id = o.product_id
WHERE o.id IS NULL;

-- SELF JOIN: pairs of products in the same category
SELECT a.name AS product_a, b.name AS product_b, a.category
FROM products a
JOIN products b ON a.category = b.category AND a.id < b.id;

-- CROSS JOIN: every city x category combination
SELECT DISTINCT c.city, p.category FROM customers c CROSS JOIN products p ORDER BY c.city LIMIT 8;

-- ---------- 8. PATTERN MATCHING ----------
SELECT name FROM customers WHERE name LIKE 'M%';          -- starts with M
SELECT name FROM products  WHERE name LIKE '%Book%';       -- contains Book
SELECT email FROM customers WHERE email REGEXP '^[a-m]';   -- starts with a-m
SELECT name FROM customers WHERE city IN ('Chennai', 'Delhi');
SELECT name, price FROM products WHERE price BETWEEN 500 AND 3000;

-- ---------- 9. SUBQUERIES & CTEs ----------
-- Scalar subquery
SELECT name, price FROM products WHERE price > (SELECT AVG(price) FROM products);

-- EXISTS / NOT EXISTS
SELECT name FROM customers c WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id AND o.status = 'Cancelled');
SELECT name FROM customers c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id);

-- Correlated subquery: most expensive product in each category
SELECT name, category, price FROM products p
WHERE price = (SELECT MAX(price) FROM products WHERE category = p.category);

-- CTE: customers who spent more than the average customer
WITH spend AS (
    SELECT customer, SUM(total) AS total_spent
    FROM order_details WHERE status <> 'Cancelled'
    GROUP BY customer
)
SELECT customer, total_spent
FROM spend
WHERE total_spent > (SELECT AVG(total_spent) FROM spend)
ORDER BY total_spent DESC;

-- Recursive CTE: month calendar for 2025 (fills months that have no sales)
WITH RECURSIVE months AS (
    SELECT DATE('2025-01-01') AS m
    UNION ALL
    SELECT DATE_ADD(m, INTERVAL 1 MONTH) FROM months WHERE m < '2025-06-01'
)
SELECT DATE_FORMAT(m.m, '%b %Y') AS month, COALESCE(SUM(d.total), 0) AS revenue
FROM months m
LEFT JOIN order_details d
       ON DATE_FORMAT(d.order_date, '%Y-%m') = DATE_FORMAT(m.m, '%Y-%m') AND d.status <> 'Cancelled'
GROUP BY m.m ORDER BY m.m;

-- ---------- 10. SET OPERATIONS ----------
SELECT city FROM customers WHERE city = 'Chennai'
UNION
SELECT city FROM customers WHERE signup_date > '2024-06-01';      -- removes duplicates

SELECT 'Customer' AS type, name FROM customers
UNION ALL
SELECT 'Product', name FROM products;                              -- keeps all rows

-- ---------- 11. WINDOW FUNCTIONS ----------
-- Ranking: ROW_NUMBER vs RANK vs DENSE_RANK
SELECT name, category, price,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS row_num,
       RANK()       OVER (PARTITION BY category ORDER BY price DESC) AS rnk,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) AS dense_rnk
FROM products;

-- Rank customers by spend
SELECT customer, SUM(total) AS total_spent,
       RANK() OVER (ORDER BY SUM(total) DESC) AS spend_rank,
       NTILE(2) OVER (ORDER BY SUM(total) DESC) AS spend_half
FROM order_details WHERE status <> 'Cancelled'
GROUP BY customer;

-- Running total and moving average
SELECT order_id, order_date, total,
       SUM(total) OVER (ORDER BY order_date, order_id) AS running_total,
       ROUND(AVG(total) OVER (ORDER BY order_date, order_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3
FROM order_details WHERE status <> 'Cancelled';

-- LAG / LEAD: compare with previous and next order of the same customer
SELECT customer, order_date, total,
       LAG(total)        OVER (PARTITION BY customer ORDER BY order_date) AS prev_total,
       LEAD(order_date)  OVER (PARTITION BY customer ORDER BY order_date) AS next_order_date,
       DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer ORDER BY order_date)) AS days_since_prev
FROM order_details WHERE status <> 'Cancelled';

-- FIRST_VALUE: cheapest product in each category
SELECT name, category, price,
       FIRST_VALUE(name) OVER (PARTITION BY category ORDER BY price) AS cheapest_in_category
FROM products;

-- Top product in each category (top-N per group)
SELECT category, product, revenue FROM (
    SELECT category, product, SUM(total) AS revenue,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(total) DESC) AS rn
    FROM order_details WHERE status <> 'Cancelled'
    GROUP BY category, product
) t WHERE rn = 1;

-- Month-over-month growth
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS ym, SUM(total) AS revenue
    FROM order_details WHERE status <> 'Cancelled'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT ym, revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY ym)) / LAG(revenue) OVER (ORDER BY ym) * 100, 1) AS mom_growth_pct
FROM monthly;

-- ---------- 12. FUNCTION, PROCEDURE, TRIGGER, TRANSACTION ----------
-- (Run in MySQL CLI or Workbench: DELIMITER is a client command)
DELIMITER $$

CREATE FUNCTION fn_tier(p_total DECIMAL(12,2)) RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    RETURN CASE WHEN p_total >= 25000 THEN 'Gold'
                WHEN p_total >= 5000  THEN 'Silver'
                ELSE 'Bronze' END;
END $$

CREATE PROCEDURE sp_place_order(IN p_customer INT, IN p_product INT, IN p_qty INT)
BEGIN
    DECLARE v_stock INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT stock INTO v_stock FROM products WHERE id = p_product FOR UPDATE;
    IF v_stock IS NULL OR v_stock < p_qty THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found or insufficient stock';
    END IF;
    INSERT INTO orders (customer_id, product_id, qty, order_date, status)
    VALUES (p_customer, p_product, p_qty, CURDATE(), 'Pending');
    COMMIT;
    SELECT LAST_INSERT_ID() AS new_order_id;
END $$

CREATE TRIGGER trg_reduce_stock
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE products SET stock = stock - NEW.qty WHERE id = NEW.product_id;
END $$

DELIMITER ;

-- Use the function
SELECT customer, SUM(total) AS spent, fn_tier(SUM(total)) AS tier
FROM order_details WHERE status <> 'Cancelled'
GROUP BY customer;

-- Use the procedure (the trigger lowers stock automatically)
CALL sp_place_order(5, 3, 2);
SELECT name, stock FROM products WHERE id = 3;     -- stock dropped from 100 to 98

-- Error handling demo: Yoga Mat has 0 stock (uncomment to see the error)
-- CALL sp_place_order(5, 5, 1);

-- Manual transaction with SAVEPOINT
START TRANSACTION;
    UPDATE products SET stock = stock + 50 WHERE id = 5;
    SAVEPOINT after_restock;
    UPDATE products SET price = price * 2 WHERE id = 5;     -- mistake
    ROLLBACK TO SAVEPOINT after_restock;                    -- undo only the price change
COMMIT;

-- Performance: EXPLAIN shows whether the index is used
EXPLAIN SELECT * FROM orders WHERE customer_id = 1;
