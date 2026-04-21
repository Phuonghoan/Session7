CREATE TABLE post (
    post_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT TRUE
);

CREATE TABLE post_like (
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id)
);

-- 1a. Kiểm tra hiệu suất trước khi tạo index
EXPLAIN ANALYZE
SELECT *
FROM post
WHERE is_public = TRUE
  AND LOWER(content) LIKE LOWER('%du lịch%');

-- 1b. Tạo Expression Index trên LOWER(content)
CREATE INDEX idx_post_lower_content
ON post (LOWER(content));

-- Kiểm tra lại hiệu suất sau khi tạo index
EXPLAIN ANALYZE
SELECT *
FROM post
WHERE is_public = TRUE
  AND LOWER(content) LIKE LOWER('%du lịch%');

-- 2a. Trước khi tạo index
EXPLAIN ANALYZE
SELECT *
FROM post
WHERE tags @> ARRAY['travel'];

-- 2b. Tạo GIN Index cho cột tags
CREATE INDEX idx_post_tags_gin
ON post
USING GIN (tags);

-- Sau khi tạo index
EXPLAIN ANALYZE
SELECT *
FROM post
WHERE tags @> ARRAY['travel'];

-- 3a. Kiểm tra trước khi tạo index
EXPLAIN ANALYZE
SELECT *
FROM post
WHERE is_public = TRUE
  AND created_at >= NOW() - INTERVAL '7 days';

-- Tạo partial index
CREATE INDEX idx_post_recent_public
ON post (created_at DESC)
WHERE is_public = TRUE;

-- 3b. Kiểm tra lại sau khi tạo index
EXPLAIN ANALYZE
SELECT *
FROM post
WHERE is_public = TRUE
  AND created_at >= NOW() - INTERVAL '7 days';

-- 4a. Tạo composite index
CREATE INDEX idx_post_user_created_at
ON post (user_id, created_at DESC);

-- 4b. Kiểm tra hiệu suất: bài đăng gần đây của nhiều bạn bè
EXPLAIN ANALYZE
SELECT *
FROM post
WHERE user_id IN (101, 102, 103, 104)
ORDER BY created_at DESC;