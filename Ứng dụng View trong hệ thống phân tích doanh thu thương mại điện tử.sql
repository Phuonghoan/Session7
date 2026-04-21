-- 1. Tạo view tổng hợp doanh thu theo khu vực
CREATE OR REPLACE VIEW v_revenue_by_region AS
SELECT
    c.region,
    SUM(o.total_amount) AS total_revenue
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region;

-- 1a. Xem top 3 khu vực có doanh thu cao nhất
SELECT
    region,
    total_revenue
FROM v_revenue_by_region
ORDER BY total_revenue DESC
LIMIT 3;

-- 2. Tạo nested view: chỉ hiển thị khu vực có doanh thu > trung bình toàn quốc
CREATE OR REPLACE VIEW v_revenue_above_avg AS
SELECT
    region,
    total_revenue
FROM v_revenue_by_region
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM v_revenue_by_region
);

-- Xem dữ liệu của view thứ 2
SELECT * FROM v_revenue_above_avg;