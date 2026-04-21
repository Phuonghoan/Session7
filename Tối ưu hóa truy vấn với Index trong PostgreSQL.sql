-- 1) Tạo các chỉ mục phù hợp

-- Hỗ trợ tìm theo author ILIKE '%Rowling%'
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX idx_book_author_trgm
ON book
USING GIN (author gin_trgm_ops);

-- Hỗ trợ tìm theo genre = 'Fantasy'
CREATE INDEX idx_book_genre
ON book (genre);


-- 2) So sánh thời gian truy vấn trước và sau khi tạo index
EXPLAIN ANALYZE
SELECT *
FROM book
WHERE author ILIKE '%Rowling%';

EXPLAIN ANALYZE
SELECT *
FROM book
WHERE genre = 'Fantasy';


-- 3a) Thử nghiệm B-tree cho genre
CREATE INDEX idx_book_genre_btree
ON book USING BTREE (genre);

EXPLAIN ANALYZE
SELECT *
FROM book
WHERE genre = 'Fantasy';


-- 3b) GIN cho title hoặc description (full-text search)
CREATE INDEX idx_book_title_fts
ON book
USING GIN (to_tsvector('simple', title));

CREATE INDEX idx_book_description_fts
ON book
USING GIN (to_tsvector('simple', description));

-- hoặc gộp cả 2 cột:
CREATE INDEX idx_book_title_description_fts
ON book
USING GIN (
    to_tsvector('simple', coalesce(title, '') || ' ' || coalesce(description, ''))
);

EXPLAIN ANALYZE
SELECT *
FROM book
WHERE to_tsvector('simple', coalesce(title, '') || ' ' || coalesce(description, ''))
      @@ plainto_tsquery('simple', 'fantasy magic');


-- 4) Clustered Index theo genre và kiểm tra hiệu suất
CREATE INDEX idx_book_genre_cluster
ON book (genre);

CLUSTER book USING idx_book_genre_cluster;

ANALYZE book;

EXPLAIN ANALYZE
SELECT *
FROM book
WHERE genre = 'Fantasy';