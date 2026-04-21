Create table customer (
	customer_id Serial Primary key,
	full_name VARCHAR (100),
	email VARCHAR(50),
	phone Numeric(10,2)
);

Create table orders (
	order_id Serial Primary key,
	customer_id INT REFERENCES customer(customer_id),
	total_amount DECIMAL (10,2),
	order_date DATE
);

-- 1. Tạo View v_order_summary hiển thị tên khách, tổng tiền và ngày đặt hàng (ẩn email và phone):
CREATE OR REPLACE VIEW v_order_summary AS
SELECT 
    c.full_name,
    o.total_amount,
    o.order_date
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id;

-- 2. Xem tất cả dữ liệu từ View:
SELECT * FROM v_order_summary;

-- 3. Tạo View lọc đơn hàng với total_amount >= 1_000_000:
CREATE OR REPLACE VIEW v_high_value_orders AS
SELECT *
FROM v_order_summary
WHERE total_amount >= 1000000;

-- 4. Tạo View thống kê tổng doanh thu theo tháng:
CREATE OR REPLACE VIEW v_monthly_sales AS
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY year, month;