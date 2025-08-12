-- RLS 정책 설정
-- 공개 데이터 테이블들에 대한 읽기 권한 허용

-- ============================= THEMES TABLE =============================
-- 테마 테이블: 모든 사용자가 읽기 가능
ALTER TABLE themes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "모든 사용자 테마 읽기 허용" ON themes
  FOR SELECT USING (true);

-- ============================= TRACKS TABLE =============================
-- 트랙 테이블: 모든 사용자가 읽기 가능
ALTER TABLE tracks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "모든 사용자 트랙 읽기 허용" ON tracks
  FOR SELECT USING (true);

-- ============================= MOODS TABLE =============================
-- 기분 테이블: 모든 사용자가 읽기 가능
ALTER TABLE moods ENABLE ROW LEVEL SECURITY;

CREATE POLICY "모든 사용자 기분 읽기 허용" ON moods
  FOR SELECT USING (true);

-- ============================= KEYWORDS TABLE =============================
-- 키워드 테이블: 모든 사용자가 읽기 가능
ALTER TABLE keywords ENABLE ROW LEVEL SECURITY;

CREATE POLICY "모든 사용자 키워드 읽기 허용" ON keywords
  FOR SELECT USING (true);

-- ============================= JUNCTION TABLES =============================
-- 관계 테이블들: 모든 사용자가 읽기 가능

ALTER TABLE theme_moods ENABLE ROW LEVEL SECURITY;
CREATE POLICY "모든 사용자 테마-기분 관계 읽기 허용" ON theme_moods
  FOR SELECT USING (true);

ALTER TABLE theme_tracks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "모든 사용자 테마-트랙 관계 읽기 허용" ON theme_tracks
  FOR SELECT USING (true);

ALTER TABLE track_keywords ENABLE ROW LEVEL SECURITY;
CREATE POLICY "모든 사용자 트랙-키워드 관계 읽기 허용" ON track_keywords
  FOR SELECT USING (true);

-- ============================= USER ANALYTICS TABLES =============================
-- 사용자 분석 테이블들: 사용자 본인의 데이터만 접근 가능

-- 사용자 기분 로그: 로그인된 사용자만 본인 데이터 CRUD 가능
ALTER TABLE user_mood_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "사용자 본인 기분 로그 조회" ON user_mood_logs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "사용자 본인 기분 로그 생성" ON user_mood_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "사용자 본인 기분 로그 수정" ON user_mood_logs
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "사용자 본인 기분 로그 삭제" ON user_mood_logs
  FOR DELETE USING (auth.uid() = user_id);

-- 사용자 재생 로그: 로그인된 사용자만 본인 데이터 CRUD 가능
ALTER TABLE user_play_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "사용자 본인 재생 로그 조회" ON user_play_logs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "사용자 본인 재생 로그 생성" ON user_play_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "사용자 본인 재생 로그 수정" ON user_play_logs
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "사용자 본인 재생 로그 삭제" ON user_play_logs
  FOR DELETE USING (auth.uid() = user_id);

-- 사용자 피드백: 로그인된 사용자만 본인 데이터 CRUD 가능
ALTER TABLE user_feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "사용자 본인 피드백 조회" ON user_feedback
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "사용자 본인 피드백 생성" ON user_feedback
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "사용자 본인 피드백 수정" ON user_feedback
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "사용자 본인 피드백 삭제" ON user_feedback
  FOR DELETE USING (auth.uid() = user_id);

-- ============================= USER PROFILES TABLE =============================
-- user_profiles 테이블은 아직 생성되지 않았으므로 나중에 추가 예정

-- ============================= 완료 메시지 =============================
COMMENT ON SCHEMA public IS 'RLS 정책이 적용된 EverySleep 스키마 - 공개 데이터는 모든 사용자 읽기 가능, 개인 데이터는 본인만 접근 가능';