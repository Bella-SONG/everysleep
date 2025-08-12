-- 완전히 새로운 정규화된 스키마
-- 기존 테이블들을 모두 제거하고 깔끔하게 시작

-- ================================
-- 0. 모든 기존 테이블 정리
-- ================================
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- ================================
-- 1. 기분(Moods) 테이블
-- ================================
CREATE TABLE moods (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  emoji TEXT,
  color TEXT,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 기분 데이터는 002 마이그레이션에서 실제 Excel 데이터로 삽입됩니다.

-- ================================
-- 2. 테마 테이블
-- ================================
CREATE TABLE themes (
  id SERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  subtitle TEXT,
  description TEXT,
  icon_path TEXT,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 테마 데이터는 별도 마이그레이션(010)에서 실제 Excel 데이터로 삽입됩니다.

-- ================================
-- 3. 트랙 테이블
-- ================================
CREATE TABLE tracks (
  id SERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  artist TEXT NOT NULL,
  url TEXT NOT NULL,
  thumbnail TEXT,
  category TEXT,
  duration_seconds INTEGER,
  bpm INTEGER,
  file_name TEXT,
  description TEXT,
  is_asmr BOOLEAN DEFAULT false,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 트랙 데이터는 별도 마이그레이션(010)에서 실제 Excel 데이터로 삽입됩니다.

-- ================================
-- 4. 키워드 테이블
-- ================================
CREATE TABLE keywords (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  category TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 키워드 데이터는 별도 마이그레이션(010)에서 실제 Excel 데이터로 삽입됩니다.

-- ================================
-- 5. 관계 테이블들
-- ================================

-- 테마-기분 관계
CREATE TABLE theme_moods (
  theme_id INTEGER REFERENCES themes(id) ON DELETE CASCADE,
  mood_id INTEGER REFERENCES moods(id) ON DELETE CASCADE,
  PRIMARY KEY (theme_id, mood_id)
);

-- 테마-트랙 관계  
CREATE TABLE theme_tracks (
  theme_id INTEGER REFERENCES themes(id) ON DELETE CASCADE,
  track_id INTEGER REFERENCES tracks(id) ON DELETE CASCADE,
  display_order INTEGER DEFAULT 0,
  PRIMARY KEY (theme_id, track_id)
);

-- 트랙-키워드 관계
CREATE TABLE track_keywords (
  track_id INTEGER REFERENCES tracks(id) ON DELETE CASCADE,
  keyword_id INTEGER REFERENCES keywords(id) ON DELETE CASCADE,
  PRIMARY KEY (track_id, keyword_id)
);

-- ================================
-- 6. 관계 데이터 삽입
-- ================================

-- 관계 데이터는 별도 마이그레이션(010)에서 실제 Excel 데이터로 삽입됩니다.

-- ================================
-- 7. 사용자 관련 테이블
-- ================================

-- 사용자 기분 기록 테이블
CREATE TABLE user_mood_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  mood_id INTEGER REFERENCES moods(id) NOT NULL,
  selected_theme_id INTEGER REFERENCES themes(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 사용자 재생 기록 테이블
CREATE TABLE user_play_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  track_id INTEGER REFERENCES tracks(id) NOT NULL,
  theme_id INTEGER REFERENCES themes(id),
  play_duration_seconds INTEGER,
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 사용자 피드백 테이블
CREATE TABLE user_feedback (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  track_id INTEGER REFERENCES tracks(id),
  theme_id INTEGER REFERENCES themes(id),
  rating INTEGER CHECK (rating IN (1, -1)), -- 1: 좋아요, -1: 싫어요
  feedback_text TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================
-- 8. RLS 정책 설정
-- ================================

-- 모든 테이블에 RLS 활성화
ALTER TABLE moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE keywords ENABLE ROW LEVEL SECURITY;
ALTER TABLE theme_moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE theme_tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE track_keywords ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_mood_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_play_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_feedback ENABLE ROW LEVEL SECURITY;

-- 읽기 전용 정책 (모든 사용자)
CREATE POLICY "Public read access" ON moods FOR SELECT USING (true);
CREATE POLICY "Public read access" ON themes FOR SELECT USING (true);
CREATE POLICY "Public read access" ON tracks FOR SELECT USING (true);
CREATE POLICY "Public read access" ON keywords FOR SELECT USING (true);
CREATE POLICY "Public read access" ON theme_moods FOR SELECT USING (true);
CREATE POLICY "Public read access" ON theme_tracks FOR SELECT USING (true);
CREATE POLICY "Public read access" ON track_keywords FOR SELECT USING (true);

-- 사용자별 개인 데이터 정책
CREATE POLICY "Users can manage their own mood logs" ON user_mood_logs
  FOR ALL USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can manage their own play logs" ON user_play_logs
  FOR ALL USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can manage their own feedback" ON user_feedback
  FOR ALL USING (auth.uid()::text = user_id::text);

-- ================================
-- 9. 인덱스 생성
-- ================================

CREATE INDEX idx_moods_display_order ON moods(display_order);
CREATE INDEX idx_themes_display_order ON themes(display_order);
CREATE INDEX idx_tracks_display_order ON tracks(display_order);
CREATE INDEX idx_tracks_category ON tracks(category);
CREATE INDEX idx_tracks_is_asmr ON tracks(is_asmr);

CREATE INDEX idx_theme_moods_theme_id ON theme_moods(theme_id);
CREATE INDEX idx_theme_moods_mood_id ON theme_moods(mood_id);
CREATE INDEX idx_theme_tracks_theme_id ON theme_tracks(theme_id);
CREATE INDEX idx_theme_tracks_track_id ON theme_tracks(track_id);
CREATE INDEX idx_theme_tracks_display_order ON theme_tracks(theme_id, display_order);
CREATE INDEX idx_track_keywords_track_id ON track_keywords(track_id);
CREATE INDEX idx_track_keywords_keyword_id ON track_keywords(keyword_id);

CREATE INDEX idx_user_mood_logs_user_id ON user_mood_logs(user_id);
CREATE INDEX idx_user_mood_logs_created_at ON user_mood_logs(created_at);
CREATE INDEX idx_user_play_logs_user_id ON user_play_logs(user_id);
CREATE INDEX idx_user_play_logs_created_at ON user_play_logs(created_at);
CREATE INDEX idx_user_feedback_user_id ON user_feedback(user_id);

-- ================================
-- 10. 편의 뷰 생성
-- ================================

-- 테마 상세 정보 뷰
CREATE VIEW theme_details AS
SELECT 
  t.id,
  t.code,
  t.title,
  t.subtitle,
  t.description,
  t.display_order,
  array_agg(DISTINCT m.name) FILTER (WHERE m.name IS NOT NULL) as moods,
  array_agg(DISTINCT tr.title) FILTER (WHERE tr.title IS NOT NULL) as track_titles,
  count(DISTINCT tr.id) as track_count
FROM themes t
LEFT JOIN theme_moods tm ON t.id = tm.theme_id
LEFT JOIN moods m ON tm.mood_id = m.id
LEFT JOIN theme_tracks tt ON t.id = tt.theme_id  
LEFT JOIN tracks tr ON tt.track_id = tr.id
GROUP BY t.id, t.code, t.title, t.subtitle, t.description, t.display_order;

-- 트랙 상세 정보 뷰
CREATE VIEW track_details AS
SELECT 
  t.id,
  t.code,
  t.title,
  t.artist,
  t.url,
  t.thumbnail,
  t.duration_seconds,
  t.description,
  t.category,
  t.is_asmr,
  array_agg(DISTINCT k.name) FILTER (WHERE k.name IS NOT NULL) as keywords,
  array_agg(DISTINCT th.title) FILTER (WHERE th.title IS NOT NULL) as themes
FROM tracks t
LEFT JOIN track_keywords tk ON t.id = tk.track_id
LEFT JOIN keywords k ON tk.keyword_id = k.id
LEFT JOIN theme_tracks tt ON t.id = tt.track_id
LEFT JOIN themes th ON tt.theme_id = th.id
GROUP BY t.id, t.code, t.title, t.artist, t.url, t.thumbnail, t.duration_seconds, t.description, t.category, t.is_asmr;