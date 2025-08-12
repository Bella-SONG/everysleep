-- 테이블 스키마 확인
-- tracks 테이블 칼럼 확인
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tracks' 
ORDER BY ordinal_position;

-- themes 테이블 칼럼 확인  
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'themes'
ORDER BY ordinal_position;

-- 실제 데이터로 칼럼명 확인
SELECT * FROM tracks LIMIT 1;
SELECT * FROM themes LIMIT 1;