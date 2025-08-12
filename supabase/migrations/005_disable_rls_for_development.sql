-- 개발 단계에서 공개 데이터 테이블들의 RLS 완전 비활성화
-- 운영 환경에서는 다시 활성화 필요

-- ============================= 공개 데이터 테이블 RLS 비활성화 =============================

-- 테마 테이블 RLS 비활성화
ALTER TABLE themes DISABLE ROW LEVEL SECURITY;

-- 트랙 테이블 RLS 비활성화  
ALTER TABLE tracks DISABLE ROW LEVEL SECURITY;

-- 기분 테이블 RLS 비활성화
ALTER TABLE moods DISABLE ROW LEVEL SECURITY;

-- 키워드 테이블 RLS 비활성화
ALTER TABLE keywords DISABLE ROW LEVEL SECURITY;

-- 관계 테이블들 RLS 비활성화
ALTER TABLE theme_moods DISABLE ROW LEVEL SECURITY;
ALTER TABLE theme_tracks DISABLE ROW LEVEL SECURITY;
ALTER TABLE track_keywords DISABLE ROW LEVEL SECURITY;

-- ============================= 사용자 데이터 테이블은 RLS 유지 =============================
-- user_mood_logs, user_play_logs, user_feedback, user_profiles 테이블들은 RLS 정책 유지

-- ============================= 완료 메시지 =============================
COMMENT ON SCHEMA public IS 'EverySleep 개발 환경 - 공개 데이터 테이블 RLS 비활성화, 사용자 데이터는 RLS 정책 유지';