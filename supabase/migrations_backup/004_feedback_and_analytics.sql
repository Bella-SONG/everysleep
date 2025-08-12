-- 트랙 피드백 테이블
CREATE TABLE IF NOT EXISTS track_feedback (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  track_id TEXT REFERENCES tracks(id) NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  is_helpful BOOLEAN,
  feedback_text TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, track_id) -- 사용자당 트랙별 하나의 피드백만
);

-- 테마 피드백 테이블
CREATE TABLE IF NOT EXISTS theme_feedback (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  theme_id TEXT REFERENCES themes(id) NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  is_effective BOOLEAN,
  feedback_text TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, theme_id)
);

-- 수면 세션 기록 테이블
CREATE TABLE IF NOT EXISTS sleep_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  theme_id TEXT REFERENCES themes(id),
  track_ids TEXT[],
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  planned_duration INTEGER, -- 타이머 설정 시간 (초)
  actual_duration INTEGER, -- 실제 재생 시간 (초)
  sleep_quality INTEGER CHECK (sleep_quality >= 1 AND sleep_quality <= 5),
  wake_up_mood TEXT,
  nature_sound_used TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 일일 통계 집계 테이블
CREATE TABLE IF NOT EXISTS daily_usage_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  date DATE NOT NULL,
  total_listening_minutes INTEGER DEFAULT 0,
  sleep_session_count INTEGER DEFAULT 0,
  meditation_minutes INTEGER DEFAULT 0,
  most_played_track_id TEXT REFERENCES tracks(id),
  most_used_theme_id TEXT REFERENCES themes(id),
  average_session_duration INTEGER,
  mood_selections JSONB, -- {"tired": 3, "anxious": 2, ...}
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id, date)
);

-- 트랙 통계 집계 테이블 (전체 사용자 대상)
CREATE TABLE IF NOT EXISTS track_analytics (
  track_id TEXT REFERENCES tracks(id) PRIMARY KEY,
  total_plays INTEGER DEFAULT 0,
  total_duration_played INTEGER DEFAULT 0, -- 초 단위
  average_rating DECIMAL(3,2),
  helpful_count INTEGER DEFAULT 0,
  completion_rate DECIMAL(3,2), -- 완주율
  skip_rate DECIMAL(3,2), -- 스킵율
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 테마 통계 집계 테이블
CREATE TABLE IF NOT EXISTS theme_analytics (
  theme_id TEXT REFERENCES themes(id) PRIMARY KEY,
  total_selections INTEGER DEFAULT 0,
  average_rating DECIMAL(3,2),
  effective_count INTEGER DEFAULT 0,
  mood_improvement_rate DECIMAL(3,2), -- 기분 개선율
  retention_rate DECIMAL(3,2), -- 재사용율
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 사용자 선호도 분석 테이블
CREATE TABLE IF NOT EXISTS user_preference_analytics (
  user_id UUID REFERENCES auth.users(id) PRIMARY KEY,
  preferred_bpm_range INT4RANGE,
  preferred_categories TEXT[],
  preferred_effect_keywords TEXT[],
  preferred_listening_time TIME,
  average_session_duration INTEGER,
  nature_sound_preference JSONB, -- {"rain": 0.3, "waves": 0.5, ...}
  last_calculated TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- RLS 정책 설정
ALTER TABLE track_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE theme_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE sleep_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_usage_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE track_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE theme_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preference_analytics ENABLE ROW LEVEL SECURITY;

-- 피드백 정책
CREATE POLICY "Users can manage own feedback" ON track_feedback
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own theme feedback" ON theme_feedback
  FOR ALL USING (auth.uid() = user_id);

-- 세션 정책
CREATE POLICY "Users can manage own sleep sessions" ON sleep_sessions
  FOR ALL USING (auth.uid() = user_id);

-- 통계 정책
CREATE POLICY "Users can view own stats" ON daily_usage_stats
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Everyone can view track analytics" ON track_analytics
  FOR SELECT USING (true);

CREATE POLICY "Everyone can view theme analytics" ON theme_analytics
  FOR SELECT USING (true);

CREATE POLICY "Users can view own preferences" ON user_preference_analytics
  FOR SELECT USING (auth.uid() = user_id);

-- 인덱스 생성
CREATE INDEX idx_track_feedback_user_track ON track_feedback(user_id, track_id);
CREATE INDEX idx_sleep_sessions_user_date ON sleep_sessions(user_id, start_time);
CREATE INDEX idx_daily_stats_user_date ON daily_usage_stats(user_id, date);

-- 통계 업데이트 함수
CREATE OR REPLACE FUNCTION update_track_analytics()
RETURNS TRIGGER AS $$
BEGIN
  -- 트랙 재생 기록이 추가될 때 통계 업데이트
  IF TG_TABLE_NAME = 'user_listening_history' THEN
    INSERT INTO track_analytics (track_id, total_plays, total_duration_played)
    VALUES (NEW.track_id, 1, NEW.duration_played)
    ON CONFLICT (track_id) DO UPDATE
    SET total_plays = track_analytics.total_plays + 1,
        total_duration_played = track_analytics.total_duration_played + NEW.duration_played,
        last_updated = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
CREATE TRIGGER update_track_stats_on_play
AFTER INSERT ON user_listening_history
FOR EACH ROW EXECUTE FUNCTION update_track_analytics();

-- 일일 통계 집계 함수
CREATE OR REPLACE FUNCTION calculate_daily_stats(p_user_id UUID, p_date DATE)
RETURNS VOID AS $$
DECLARE
  v_total_minutes INTEGER;
  v_sleep_count INTEGER;
  v_meditation_minutes INTEGER;
  v_most_played TEXT;
  v_most_theme TEXT;
  v_avg_duration INTEGER;
  v_mood_data JSONB;
BEGIN
  -- 총 청취 시간 계산
  SELECT COALESCE(SUM(duration_played) / 60, 0)
  INTO v_total_minutes
  FROM user_listening_history
  WHERE user_id = p_user_id 
    AND DATE(played_at) = p_date;

  -- 수면 세션 수 계산
  SELECT COUNT(*)
  INTO v_sleep_count
  FROM sleep_sessions
  WHERE user_id = p_user_id 
    AND DATE(start_time) = p_date;

  -- 명상 카테고리 청취 시간
  SELECT COALESCE(SUM(h.duration_played) / 60, 0)
  INTO v_meditation_minutes
  FROM user_listening_history h
  JOIN tracks t ON h.track_id = t.id
  WHERE h.user_id = p_user_id 
    AND DATE(h.played_at) = p_date
    AND t.category = '명상';

  -- 가장 많이 재생한 트랙
  SELECT track_id
  INTO v_most_played
  FROM user_listening_history
  WHERE user_id = p_user_id 
    AND DATE(played_at) = p_date
  GROUP BY track_id
  ORDER BY COUNT(*) DESC
  LIMIT 1;

  -- 가장 많이 사용한 테마
  SELECT selected_theme_id
  INTO v_most_theme
  FROM user_mood_logs
  WHERE user_id = p_user_id 
    AND DATE(created_at) = p_date
  GROUP BY selected_theme_id
  ORDER BY COUNT(*) DESC
  LIMIT 1;

  -- 평균 세션 시간
  SELECT AVG(duration_played)
  INTO v_avg_duration
  FROM user_listening_history
  WHERE user_id = p_user_id 
    AND DATE(played_at) = p_date;

  -- 기분 선택 집계
  SELECT jsonb_object_agg(mood, count)
  INTO v_mood_data
  FROM (
    SELECT mood, COUNT(*) as count
    FROM user_mood_logs
    WHERE user_id = p_user_id 
      AND DATE(created_at) = p_date
    GROUP BY mood
  ) mood_counts;

  -- 일일 통계 삽입/업데이트
  INSERT INTO daily_usage_stats (
    user_id, date, total_listening_minutes, sleep_session_count,
    meditation_minutes, most_played_track_id, most_used_theme_id,
    average_session_duration, mood_selections
  ) VALUES (
    p_user_id, p_date, v_total_minutes, v_sleep_count,
    v_meditation_minutes, v_most_played, v_most_theme,
    v_avg_duration, v_mood_data
  )
  ON CONFLICT (user_id, date) DO UPDATE
  SET total_listening_minutes = EXCLUDED.total_listening_minutes,
      sleep_session_count = EXCLUDED.sleep_session_count,
      meditation_minutes = EXCLUDED.meditation_minutes,
      most_played_track_id = EXCLUDED.most_played_track_id,
      most_used_theme_id = EXCLUDED.most_used_theme_id,
      average_session_duration = EXCLUDED.average_session_duration,
      mood_selections = EXCLUDED.mood_selections;
END;
$$ LANGUAGE plpgsql;

-- 사용자 선호도 분석 함수
CREATE OR REPLACE FUNCTION analyze_user_preferences(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
  v_bpm_range INT4RANGE;
  v_categories TEXT[];
  v_keywords TEXT[];
  v_listening_time TIME;
  v_avg_duration INTEGER;
  v_nature_prefs JSONB;
BEGIN
  -- 선호 BPM 범위 계산 (상위 25%-75% 구간)
  WITH bpm_stats AS (
    SELECT percentile_cont(0.25) WITHIN GROUP (ORDER BY t.bpm) as q1,
           percentile_cont(0.75) WITHIN GROUP (ORDER BY t.bpm) as q3
    FROM user_listening_history h
    JOIN tracks t ON h.track_id = t.id
    WHERE h.user_id = p_user_id 
      AND t.bpm IS NOT NULL
  )
  SELECT int4range(q1::int, q3::int, '[]')
  INTO v_bpm_range
  FROM bpm_stats;

  -- 선호 카테고리 (상위 3개)
  SELECT array_agg(category ORDER BY play_count DESC)
  INTO v_categories
  FROM (
    SELECT t.category, COUNT(*) as play_count
    FROM user_listening_history h
    JOIN tracks t ON h.track_id = t.id
    WHERE h.user_id = p_user_id
    GROUP BY t.category
    ORDER BY play_count DESC
    LIMIT 3
  ) top_categories;

  -- 선호 효과 키워드 (상위 5개)
  SELECT array_agg(DISTINCT keyword)
  INTO v_keywords
  FROM (
    SELECT unnest(t.effect_keywords) as keyword, COUNT(*) as count
    FROM user_listening_history h
    JOIN tracks t ON h.track_id = t.id
    WHERE h.user_id = p_user_id
    GROUP BY keyword
    ORDER BY count DESC
    LIMIT 5
  ) top_keywords;

  -- 주요 청취 시간대
  SELECT MODE() WITHIN GROUP (ORDER BY date_trunc('hour', played_at)::time)
  INTO v_listening_time
  FROM user_listening_history
  WHERE user_id = p_user_id;

  -- 평균 세션 길이
  SELECT AVG(duration_played)
  INTO v_avg_duration
  FROM user_listening_history
  WHERE user_id = p_user_id;

  -- 자연음 선호도
  WITH nature_stats AS (
    SELECT nature_sound_used, COUNT(*) as count
    FROM sleep_sessions
    WHERE user_id = p_user_id 
      AND nature_sound_used IS NOT NULL
    GROUP BY nature_sound_used
  )
  SELECT jsonb_object_agg(nature_sound_used, count::float / SUM(count) OVER ())
  INTO v_nature_prefs
  FROM nature_stats;

  -- 선호도 업데이트
  INSERT INTO user_preference_analytics (
    user_id, preferred_bpm_range, preferred_categories,
    preferred_effect_keywords, preferred_listening_time,
    average_session_duration, nature_sound_preference
  ) VALUES (
    p_user_id, v_bpm_range, v_categories, v_keywords,
    v_listening_time, v_avg_duration, v_nature_prefs
  )
  ON CONFLICT (user_id) DO UPDATE
  SET preferred_bpm_range = EXCLUDED.preferred_bpm_range,
      preferred_categories = EXCLUDED.preferred_categories,
      preferred_effect_keywords = EXCLUDED.preferred_effect_keywords,
      preferred_listening_time = EXCLUDED.preferred_listening_time,
      average_session_duration = EXCLUDED.average_session_duration,
      nature_sound_preference = EXCLUDED.nature_sound_preference,
      last_calculated = NOW();
END;
$$ LANGUAGE plpgsql;