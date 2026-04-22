-- TẠO BẢNG

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category TEXT[],
    price NUMERIC(10,2)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    product_id INT REFERENCES products(product_id),
    order_date DATE,
    quantity INT
);

-- 1) THÊM DỮ LIỆU MẪU

INSERT INTO customers (full_name, email, city) VALUES
('Nguyen Van A', 'a@gmail.com', 'HCM'),
('Tran Thi B', 'b@gmail.com', 'Ha Noi'),
('Le Van C', 'c@gmail.com', 'Da Nang'),
('Pham Thi D', 'd@gmail.com', 'Can Tho'),
('Hoang Van E', 'e@gmail.com', 'HCM');

INSERT INTO products (product_name, category, price) VALUES
('iPhone 14', ARRAY['Electronics','Phone'], 22000000),
('Samsung TV', ARRAY['Electronics','Home'], 15000000),
('Laptop Dell', ARRAY['Electronics','Computer'], 18000000),
('Ban Phim Co', ARRAY['Electronics','Accessory'], 800000),
('Noi Chien Khong Dau', ARRAY['Home','Kitchen'], 2500000);

INSERT INTO orders (customer_id, product_id, order_date, quantity) VALUES
(1, 1, '2026-04-01', 1),
(2, 2, '2026-04-02', 1),
(3, 3, '2026-04-03', 2),
(4, 4, '2026-04-04', 3),
(5, 5, '2026-04-05', 1),
(1, 3, '2026-04-06', 1),
(2, 4, '2026-04-07', 2),
(3, 1, '2026-04-08', 1),
(4, 2, '2026-04-09', 1),
(5, 3, '2026-04-10', 1);

-- 2) TẠO INDEX

-- a. B-tree cho email
CREATE INDEX idx_customers_email_btree
ON customers(email);

-- b. Hash cho city
CREATE INDEX idx_customers_city_hash
ON customers USING HASH(city);

-- c. GIN cho category
CREATE INDEX idx_products_category_gin
ON products USING GIN(category);

-- d. GiST cho price
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE INDEX idx_products_price_gist
ON products USING GIST(price);

-- 3) TRUY VẤN THỬ SAU KHI TẠO INDEX

-- a. Tìm khách hàng theo email cụ thể
SELECT *
FROM customers
WHERE email = 'a@gmail.com';

-- b. Tìm sản phẩm có category chứa 'Electronics'
SELECT *
FROM products
WHERE category @> ARRAY['Electronics'];

-- c. Tìm sản phẩm trong khoảng giá từ 500 đến 1000
SELECT *
FROM products
WHERE price BETWEEN 500 AND 1000;

-- d. EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT *
FROM customers
WHERE email = 'a@gmail.com';

EXPLAIN ANALYZE
SELECT *
FROM products
WHERE category @> ARRAY['Electronics'];

EXPLAIN ANALYZE
SELECT *
FROM products
WHERE price BETWEEN 500 AND 1000;

-- 4) CLUSTERED INDEX TRÊN orders THEO order_date

CREATE INDEX idx_orders_order_date
ON orders(order_date);

CLUSTER orders USING idx_orders_order_date;

-- 5) VIEW

-- a. Top 3 khách hàng mua nhiều nhất
CREATE OR REPLACE VIEW v_top_customers AS
SELECT
    c.customer_id,
    c.full_name,
    SUM(o.quantity) AS total_quantity
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_quantity DESC;

SELECT *
FROM v_top_customers
LIMIT 3;

-- b. Tổng doanh thu theo từng sản phẩm
CREATE OR REPLACE VIEW v_product_revenue AS
SELECT
    p.product_id,
    p.product_name,
    SUM(o.quantity * p.price) AS total_revenue
FROM products p
JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name;

SELECT *
FROM v_product_revenue;

-- 6) VIEW CÓ THỂ GHI

CREATE OR REPLACE VIEW v_customer_city AS
SELECT customer_id, full_name, city
FROM customers
WITH CHECK OPTION;

-- cập nhật qua view
UPDATE v_customer_city
SET city = 'Hai Phong'
WHERE customer_id = 1;

-- kiểm tra lại bảng gốc
SELECT *
FROM customers
WHERE customer_id = 1;