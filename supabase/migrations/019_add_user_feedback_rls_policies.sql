-- user_feedback 테이블 RLS 정책 추가
-- 다른 테이블들과 동일한 패턴으로 설정

-- RLS 활성화 (다른 테이블들과 동일)
ALTER TABLE user_feedback ENABLE ROW LEVEL SECURITY;

-- 기존 정책 삭제
DROP POLICY IF EXISTS "Public read access" ON user_feedback;
DROP POLICY IF EXISTS "Anyone can insert feedback" ON user_feedback;
DROP POLICY IF EXISTS "Anyone can read their own feedback" ON user_feedback;

-- 다른 테이블들과 동일한 공개 읽기 정책
CREATE POLICY "Public read access" ON user_feedback FOR SELECT USING (true);

-- 피드백 작성을 위한 INSERT 정책 추가
CREATE POLICY "Public insert access" ON user_feedback FOR INSERT WITH CHECK (true);

-- 기존 정책들 확인
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd,
    permissive,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'user_feedback'
ORDER BY policyname;