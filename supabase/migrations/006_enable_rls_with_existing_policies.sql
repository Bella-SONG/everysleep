-- RLS 다시 활성화 (기존 정책들이 작동하도록)
-- 기존의 "Public read access" 정책들을 활용

-- ============================= 공개 데이터 테이블 RLS 활성화 =============================

-- 테마 테이블 RLS 활성화
ALTER TABLE themes ENABLE ROW LEVEL SECURITY;

-- 트랙 테이블 RLS 활성화  
ALTER TABLE tracks ENABLE ROW LEVEL SECURITY;

-- 기분 테이블 RLS 활성화
ALTER TABLE moods ENABLE ROW LEVEL SECURITY;

-- 키워드 테이블 RLS 활성화
ALTER TABLE keywords ENABLE ROW LEVEL SECURITY;

-- 관계 테이블들 RLS 활성화
ALTER TABLE theme_moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE theme_tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE track_keywords ENABLE ROW LEVEL SECURITY;

-- ============================= 기존 정책 상태 확인 =============================
-- 현재 적용된 정책들이 정상적으로 작동할 것임:
-- - "Public read access" 정책들이 모든 사용자(anon, authenticated)에게 SELECT 권한 제공
-- - "공개 테마 데이터 읽기" 등의 정책들도 함께 작동

-- ============================= 완료 메시지 =============================
COMMENT ON SCHEMA public IS 'EverySleep 스키마 - RLS 활성화됨, 기존 Public read access 정책들이 작동';