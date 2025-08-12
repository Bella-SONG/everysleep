-- 기존 tracks 테이블에 새 컬럼 추가
ALTER TABLE tracks 
ADD COLUMN IF NOT EXISTS bpm INTEGER,
ADD COLUMN IF NOT EXISTS file_name TEXT,
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS effect_keywords TEXT[],
ADD COLUMN IF NOT EXISTS is_asmr BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS display_order INTEGER;

-- 테마 테이블 생성
CREATE TABLE IF NOT EXISTS themes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT,
  description TEXT,
  track_ids TEXT[] NOT NULL,
  moods TEXT[] NOT NULL,
  icon_path TEXT,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 테마 RLS 정책
ALTER TABLE themes ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 테마를 읽을 수 있음
CREATE POLICY "Themes are viewable by all users" ON themes
  FOR SELECT USING (true);

-- 테마-트랙 관계 뷰 생성 (편의를 위해)
CREATE OR REPLACE VIEW theme_tracks AS
SELECT 
  t.id as theme_id,
  t.title as theme_title,
  tr.id as track_id,
  tr.title as track_title,
  tr.artist,
  tr.url,
  tr.thumbnail,
  tr.category,
  tr.duration_seconds,
  tr.bpm,
  tr.description,
  tr.effect_keywords,
  tr.is_asmr
FROM themes t
CROSS JOIN LATERAL unnest(t.track_ids) AS track_id
JOIN tracks tr ON tr.id = track_id;

-- 사용자 기분 선택 기록 테이블
CREATE TABLE IF NOT EXISTS user_mood_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  mood TEXT NOT NULL,
  selected_theme_id TEXT REFERENCES themes(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 사용자 기분 기록 RLS
ALTER TABLE user_mood_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own mood logs" ON user_mood_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own mood logs" ON user_mood_logs
  FOR SELECT USING (auth.uid() = user_id);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_tracks_category ON tracks(category);
CREATE INDEX IF NOT EXISTS idx_tracks_bpm ON tracks(bpm);
CREATE INDEX IF NOT EXISTS idx_themes_display_order ON themes(display_order);
CREATE INDEX IF NOT EXISTS idx_user_mood_logs_user_id ON user_mood_logs(user_id);

-- 업데이트 타임스탬프 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ language 'plpgsql';

-- themes 테이블에 트리거 적용
CREATE TRIGGER update_themes_updated_at BEFORE UPDATE ON themes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();