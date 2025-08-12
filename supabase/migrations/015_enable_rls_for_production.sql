-- RLS 활성화 및 공개 읽기 정책 적용
-- 개발/디버깅이 완료되었으므로 보안을 위해 RLS 재활성화

-- ============================= 모든 테이블 RLS 활성화 =============================

-- 기분 테이블 RLS 활성화
ALTER TABLE moods ENABLE ROW LEVEL SECURITY;

-- 테마 테이블 RLS 활성화
ALTER TABLE themes ENABLE ROW LEVEL SECURITY;

-- 트랙 테이블 RLS 활성화  
ALTER TABLE tracks ENABLE ROW LEVEL SECURITY;

-- 키워드 테이블 RLS 활성화
ALTER TABLE keywords ENABLE ROW LEVEL SECURITY;

-- 관계 테이블들 RLS 활성화
ALTER TABLE theme_moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE theme_tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE track_keywords ENABLE ROW LEVEL SECURITY;

-- ============================= 공개 읽기 정책 확인 및 생성 =============================

-- 기분 테이블 공개 읽기 정책 (이미 존재할 수 있음)
DROP POLICY IF EXISTS "Public read access" ON moods;
CREATE POLICY "Public read access" ON moods FOR SELECT USING (true);

-- 테마 테이블 공개 읽기 정책
DROP POLICY IF EXISTS "Public read access" ON themes;
CREATE POLICY "Public read access" ON themes FOR SELECT USING (true);

-- 트랙 테이블 공개 읽기 정책
DROP POLICY IF EXISTS "Public read access" ON tracks;
CREATE POLICY "Public read access" ON tracks FOR SELECT USING (true);

-- 키워드 테이블 공개 읽기 정책
DROP POLICY IF EXISTS "Public read access" ON keywords;
CREATE POLICY "Public read access" ON keywords FOR SELECT USING (true);

-- 관계 테이블들 공개 읽기 정책
DROP POLICY IF EXISTS "Public read access" ON theme_moods;
CREATE POLICY "Public read access" ON theme_moods FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read access" ON theme_tracks;
CREATE POLICY "Public read access" ON theme_tracks FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read access" ON track_keywords;
CREATE POLICY "Public read access" ON track_keywords FOR SELECT USING (true);

-- ============================= RLS 상태 확인 =============================

-- RLS가 제대로 활성화되었는지 확인
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename IN ('moods', 'themes', 'tracks', 'keywords', 'theme_moods', 'theme_tracks', 'track_keywords')
ORDER BY tablename;

-- 정책들이 제대로 생성되었는지 확인
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;