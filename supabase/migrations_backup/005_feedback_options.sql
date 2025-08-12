-- 피드백 옵션 테이블 생성
CREATE TABLE IF NOT EXISTS feedback_options (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT NOT NULL CHECK (type IN ('positive', 'negative')), -- 긍정/부정 피드백 구분
  option_text TEXT NOT NULL,
  icon TEXT, -- 아이콘 이름 (선택사항)
  display_order INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- track_feedback 테이블 수정 (rating을 boolean으로 변경하고 선택 옵션 추가)
ALTER TABLE track_feedback 
DROP CONSTRAINT IF EXISTS track_feedback_rating_check,
ADD COLUMN IF NOT EXISTS is_positive BOOLEAN, -- true: 따봉업, false: 따봉다운
ADD COLUMN IF NOT EXISTS selected_options UUID[], -- 선택한 옵션들의 ID 배열
DROP COLUMN IF EXISTS rating,
DROP COLUMN IF EXISTS is_helpful;

-- theme_feedback 테이블도 동일하게 수정
ALTER TABLE theme_feedback
DROP CONSTRAINT IF EXISTS theme_feedback_rating_check,
ADD COLUMN IF NOT EXISTS is_positive BOOLEAN,
ADD COLUMN IF NOT EXISTS selected_options UUID[],
DROP COLUMN IF EXISTS rating,
DROP COLUMN IF EXISTS is_effective;

-- 피드백 옵션 기본 데이터 삽입
INSERT INTO feedback_options (type, option_text, icon, display_order) VALUES
-- 긍정적 피드백 옵션
('positive', '잠이 잘 왔어요', '😴', 1),
('positive', '마음이 편안해졌어요', '😌', 2),
('positive', '집중이 잘됐어요', '🎯', 3),
('positive', '스트레스가 줄었어요', '😮‍💨', 4),
('positive', '기분이 좋아졌어요', '😊', 5),
('positive', '몸이 이완됐어요', '🧘', 6),
('positive', '귀가 편안해졌어요', '👂', 7),

-- 부정적 피드백 옵션
('negative', '잠이 안 왔어요', '😵', 1),
('negative', '너무 시끄러웠어요', '🔊', 2),
('negative', '지루했어요', '😑', 3),
('negative', '집중이 안됐어요', '🌀', 4),
('negative', '불안해졌어요', '😰', 5),
('negative', '음질이 좋지 않았어요', '📻', 6),
('negative', '길이가 적당하지 않았어요', '⏰', 7),
('negative', '제 취향이 아니에요', '🤷', 8);

-- 피드백 통계를 위한 뷰 생성
CREATE OR REPLACE VIEW feedback_summary AS
SELECT 
  tf.track_id,
  t.title as track_title,
  COUNT(*) as total_feedback,
  COUNT(*) FILTER (WHERE tf.is_positive = true) as positive_count,
  COUNT(*) FILTER (WHERE tf.is_positive = false) as negative_count,
  ROUND(
    COUNT(*) FILTER (WHERE tf.is_positive = true)::decimal / COUNT(*) * 100, 2
  ) as positive_percentage,
  
  -- 가장 많이 선택된 긍정 옵션
  (
    SELECT fo.option_text
    FROM track_feedback tf2
    CROSS JOIN LATERAL unnest(tf2.selected_options) AS option_id
    JOIN feedback_options fo ON fo.id = option_id
    WHERE tf2.track_id = tf.track_id 
      AND tf2.is_positive = true
      AND fo.type = 'positive'
    GROUP BY fo.option_text
    ORDER BY COUNT(*) DESC
    LIMIT 1
  ) as top_positive_reason,
  
  -- 가장 많이 선택된 부정 옵션
  (
    SELECT fo.option_text
    FROM track_feedback tf2
    CROSS JOIN LATERAL unnest(tf2.selected_options) AS option_id
    JOIN feedback_options fo ON fo.id = option_id
    WHERE tf2.track_id = tf.track_id 
      AND tf2.is_positive = false
      AND fo.type = 'negative'
    GROUP BY fo.option_text
    ORDER BY COUNT(*) DESC
    LIMIT 1
  ) as top_negative_reason

FROM track_feedback tf
JOIN tracks t ON tf.track_id = t.id
GROUP BY tf.track_id, t.title;

-- 테마 피드백 요약 뷰
CREATE OR REPLACE VIEW theme_feedback_summary AS
SELECT 
  tf.theme_id,
  th.title as theme_title,
  COUNT(*) as total_feedback,
  COUNT(*) FILTER (WHERE tf.is_positive = true) as positive_count,
  COUNT(*) FILTER (WHERE tf.is_positive = false) as negative_count,
  ROUND(
    COUNT(*) FILTER (WHERE tf.is_positive = true)::decimal / COUNT(*) * 100, 2
  ) as positive_percentage

FROM theme_feedback tf
JOIN themes th ON tf.theme_id = th.id
GROUP BY tf.theme_id, th.title;

-- 사용자별 피드백 패턴 분석 뷰
CREATE OR REPLACE VIEW user_feedback_patterns AS
SELECT 
  tf.user_id,
  COUNT(*) as total_feedbacks,
  COUNT(*) FILTER (WHERE tf.is_positive = true) as positive_feedbacks,
  
  -- 가장 자주 선택하는 긍정 이유
  (
    SELECT fo.option_text
    FROM track_feedback tf2
    CROSS JOIN LATERAL unnest(tf2.selected_options) AS option_id
    JOIN feedback_options fo ON fo.id = option_id
    WHERE tf2.user_id = tf.user_id 
      AND tf2.is_positive = true
      AND fo.type = 'positive'
    GROUP BY fo.option_text
    ORDER BY COUNT(*) DESC
    LIMIT 1
  ) as preferred_positive_reason,
  
  -- 가장 자주 선택하는 부정 이유
  (
    SELECT fo.option_text
    FROM track_feedback tf2
    CROSS JOIN LATERAL unnest(tf2.selected_options) AS option_id
    JOIN feedback_options fo ON fo.id = option_id
    WHERE tf2.user_id = tf.user_id 
      AND tf2.is_positive = false
      AND fo.type = 'negative'
    GROUP BY fo.option_text
    ORDER BY COUNT(*) DESC
    LIMIT 1
  ) as main_complaint

FROM track_feedback tf
GROUP BY tf.user_id;

-- 피드백 옵션 RLS 정책
ALTER TABLE feedback_options ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view feedback options" ON feedback_options
  FOR SELECT USING (is_active = true);

-- 인덱스 추가
CREATE INDEX idx_feedback_options_type ON feedback_options(type, display_order);
CREATE INDEX idx_track_feedback_positive ON track_feedback(track_id, is_positive);
CREATE INDEX idx_theme_feedback_positive ON theme_feedback(theme_id, is_positive);