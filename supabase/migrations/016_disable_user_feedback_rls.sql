-- user_feedback 테이블 RLS 비활성화 (개발 환경용)
-- 피드백 제출 권한 문제 해결

-- user_feedback 테이블 RLS 비활성화
ALTER TABLE user_feedback DISABLE ROW LEVEL SECURITY;

-- user_mood_logs, user_play_logs도 함께 비활성화 (일관성을 위해)
ALTER TABLE user_mood_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_play_logs DISABLE ROW LEVEL SECURITY;

-- 상태 확인
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename IN ('user_feedback', 'user_mood_logs', 'user_play_logs')
ORDER BY tablename;