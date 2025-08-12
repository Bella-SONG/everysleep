-- 사용자 청취 기록 테이블
CREATE TABLE IF NOT EXISTS user_listening_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  track_id TEXT REFERENCES tracks(id) NOT NULL,
  played_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  duration_played INTEGER DEFAULT 0, -- 실제 재생된 시간 (초)
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 사용자 설정 테이블
CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  preference_key TEXT NOT NULL,
  preference_value JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, preference_key)
);

-- RLS 정책 설정
ALTER TABLE user_listening_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- 사용자 청취 기록 정책
CREATE POLICY "Users can insert their own listening history" ON user_listening_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own listening history" ON user_listening_history
  FOR SELECT USING (auth.uid() = user_id);

-- 사용자 설정 정책
CREATE POLICY "Users can manage their own preferences" ON user_preferences
  FOR ALL USING (auth.uid() = user_id);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_listening_history_user_id ON user_listening_history(user_id);
CREATE INDEX IF NOT EXISTS idx_user_listening_history_track_id ON user_listening_history(track_id);
CREATE INDEX IF NOT EXISTS idx_user_listening_history_played_at ON user_listening_history(played_at);
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_key ON user_preferences(user_id, preference_key);