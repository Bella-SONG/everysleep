-- user_feedback 테이블 RLS 강제 비활성화
-- 권한 문제 해결

-- 기존 정책들 모두 삭제
DROP POLICY IF EXISTS "Users can manage their own feedback" ON user_feedback;
DROP POLICY IF EXISTS "Public read access" ON user_feedback;
DROP POLICY IF EXISTS "Public write access" ON user_feedback;

-- RLS 완전 비활성화
ALTER TABLE user_feedback DISABLE ROW LEVEL SECURITY;

-- 다른 사용자 테이블들도 함께 비활성화 (일관성)
ALTER TABLE user_mood_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_play_logs DISABLE ROW LEVEL SECURITY;

-- RLS 상태 확인
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename LIKE 'user_%'
ORDER BY tablename;