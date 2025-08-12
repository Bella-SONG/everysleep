-- 개발/디버깅을 위해 임시로 RLS 완전 비활성화
-- 문제 해결 후 다시 활성화 필요

-- ============================= 공개 데이터 테이블 RLS 비활성화 =============================

-- 기분 테이블 RLS 비활성화
ALTER TABLE moods DISABLE ROW LEVEL SECURITY;

-- 테마 테이블 RLS 비활성화
ALTER TABLE themes DISABLE ROW LEVEL SECURITY;

-- 트랙 테이블 RLS 비활성화  
ALTER TABLE tracks DISABLE ROW LEVEL SECURITY;

-- 키워드 테이블 RLS 비활성화
ALTER TABLE keywords DISABLE ROW LEVEL SECURITY;

-- 관계 테이블들 RLS 비활성화
ALTER TABLE theme_moods DISABLE ROW LEVEL SECURITY;
ALTER TABLE theme_tracks DISABLE ROW LEVEL SECURITY;
ALTER TABLE track_keywords DISABLE ROW LEVEL SECURITY;

-- ============================= 데이터 존재 여부 확인 =============================

-- 각 테이블의 레코드 수 확인
SELECT 'moods' as table_name, COUNT(*) as record_count FROM moods
UNION ALL
SELECT 'themes' as table_name, COUNT(*) as record_count FROM themes  
UNION ALL
SELECT 'tracks' as table_name, COUNT(*) as record_count FROM tracks
UNION ALL
SELECT 'keywords' as table_name, COUNT(*) as record_count FROM keywords
UNION ALL
SELECT 'theme_moods' as table_name, COUNT(*) as record_count FROM theme_moods
UNION ALL
SELECT 'theme_tracks' as table_name, COUNT(*) as record_count FROM theme_tracks
UNION ALL
SELECT 'track_keywords' as table_name, COUNT(*) as record_count FROM track_keywords
ORDER BY table_name;

-- 첫 번째 기분 데이터 확인
SELECT * FROM moods ORDER BY display_order LIMIT 3;

-- 첫 번째 테마 데이터 확인  
SELECT * FROM themes ORDER BY display_order LIMIT 3;

-- 첫 번째 트랙 데이터 확인
SELECT code, title, category, is_asmr FROM tracks ORDER BY display_order LIMIT 5;