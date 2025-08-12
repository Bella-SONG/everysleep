-- 완전 정규화된 스키마로 리팩토링
-- 시퀀스 기반 PK 사용

-- ================================
-- 0. 기존 뷰 정리
-- ================================
DROP VIEW IF EXISTS theme_tracks;

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

-- 기분 데이터 삽입
INSERT INTO moods (name, emoji, color, display_order) VALUES 
('푹 자고 싶어요', '😴', '#42A5F5', 1),
('낮잠이 필요해요', '💤', '#9C27B0', 2),  
('지쳤어요', '😟', '#FF7043', 3),
('귀에서 소리가 나요', '👂', '#5C6BC0', 4),
('기운이 없어요', '🌅', '#50C878', 5),
('조용히 쉬고싶어요', '🧘', '#4CAF50', 6);

-- ================================
-- 2. 새로운 테마 테이블 (시퀀스 PK)
-- ================================
CREATE TABLE themes_new (
  id SERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL, -- 기존 'theme_1' 같은 코드
  title TEXT NOT NULL,
  subtitle TEXT,
  description TEXT,
  icon_path TEXT,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 기존 테마 데이터를 새 테이블로 복사
INSERT INTO themes_new (code, title, subtitle, description, display_order, created_at, updated_at)
SELECT id, title, subtitle, description, display_order, created_at, updated_at 
FROM themes 
ORDER BY display_order;

-- ================================
-- 3. 새로운 트랙 테이블 (시퀀스 PK)  
-- ================================
CREATE TABLE tracks_new (
  id SERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL, -- 기존 'S001' 같은 코드
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

-- 기존 트랙 데이터를 새 테이블로 복사
INSERT INTO tracks_new (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order, created_at)
SELECT id, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order, created_at
FROM tracks 
ORDER BY display_order;

-- ================================
-- 4. 키워드 테이블
-- ================================
CREATE TABLE keywords (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  category TEXT, -- '효과', '장르', '분위기' 등
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 기존 effect_keywords에서 키워드 추출하여 삽입
INSERT INTO keywords (name, category) 
SELECT DISTINCT 
  trim(keyword) as name,
  '효과' as category
FROM (
  SELECT unnest(effect_keywords) as keyword 
  FROM tracks 
  WHERE effect_keywords IS NOT NULL
) t
WHERE trim(keyword) != '';

-- ================================
-- 5. 관계 테이블들
-- ================================

-- 테마-기분 관계
CREATE TABLE theme_moods (
  theme_id INTEGER REFERENCES themes_new(id) ON DELETE CASCADE,
  mood_id INTEGER REFERENCES moods(id) ON DELETE CASCADE,
  PRIMARY KEY (theme_id, mood_id)
);

-- 테마-트랙 관계  
CREATE TABLE theme_tracks (
  theme_id INTEGER REFERENCES themes_new(id) ON DELETE CASCADE,
  track_id INTEGER REFERENCES tracks_new(id) ON DELETE CASCADE,
  display_order INTEGER DEFAULT 0,
  PRIMARY KEY (theme_id, track_id)
);

-- 트랙-키워드 관계
CREATE TABLE track_keywords (
  track_id INTEGER REFERENCES tracks_new(id) ON DELETE CASCADE,
  keyword_id INTEGER REFERENCES keywords(id) ON DELETE CASCADE,
  PRIMARY KEY (track_id, keyword_id)
);

-- ================================
-- 6. 관계 데이터 마이그레이션
-- ================================

-- 테마-기분 관계 데이터 삽입
INSERT INTO theme_moods (theme_id, mood_id)
SELECT tn.id, m.id
FROM themes_new tn
CROSS JOIN LATERAL unnest(
  CASE tn.code 
    WHEN 'theme_1' THEN ARRAY['푹 자고 싶어요', '낮잠이 필요해요']
    WHEN 'theme_2' THEN ARRAY['지쳤어요'] 
    WHEN 'theme_3' THEN ARRAY['귀에서 소리가 나요']
    WHEN 'theme_4' THEN ARRAY['기운이 없어요']
    WHEN 'theme_5' THEN ARRAY['조용히 쉬고싶어요']
    WHEN 'theme_6' THEN ARRAY['조용히 쉬고싶어요'] -- 자연의 음악도 휴식용
    ELSE ARRAY[]::TEXT[]
  END
) AS mood_names(mood_name)
JOIN moods m ON m.name = mood_name;

-- 테마-트랙 관계 데이터 삽입
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT tn.id, tkn.id, 
  track_codes.ord as display_order
FROM themes_new tn
JOIN themes t_old ON t_old.id = tn.code
CROSS JOIN LATERAL unnest(t_old.track_ids) WITH ORDINALITY AS track_codes(track_code, ord)
JOIN tracks_new tkn ON tkn.code = track_codes.track_code;

-- 트랙-키워드 관계 데이터 삽입
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tkn.id, k.id
FROM tracks_new tkn
JOIN tracks t_old ON t_old.id = tkn.code
CROSS JOIN LATERAL unnest(t_old.effect_keywords) AS keyword_names(keyword_name)
JOIN keywords k ON k.name = trim(keyword_name)
WHERE t_old.effect_keywords IS NOT NULL;

-- ================================
-- 7. RLS 정책 설정
-- ================================

-- 모든 테이블에 RLS 활성화
ALTER TABLE moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE themes_new ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracks_new ENABLE ROW LEVEL SECURITY;
ALTER TABLE keywords ENABLE ROW LEVEL SECURITY;
ALTER TABLE theme_moods ENABLE ROW LEVEL SECURITY;
ALTER TABLE theme_tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE track_keywords ENABLE ROW LEVEL SECURITY;

-- 읽기 전용 정책 (모든 사용자)
CREATE POLICY "Public read access" ON moods FOR SELECT USING (true);
CREATE POLICY "Public read access" ON themes_new FOR SELECT USING (true);
CREATE POLICY "Public read access" ON tracks_new FOR SELECT USING (true);
CREATE POLICY "Public read access" ON keywords FOR SELECT USING (true);
CREATE POLICY "Public read access" ON theme_moods FOR SELECT USING (true);
CREATE POLICY "Public read access" ON theme_tracks FOR SELECT USING (true);
CREATE POLICY "Public read access" ON track_keywords FOR SELECT USING (true);

-- ================================
-- 8. 인덱스 생성
-- ================================

-- 성능 최적화를 위한 인덱스
CREATE INDEX idx_themes_new_display_order ON themes_new(display_order);
CREATE INDEX idx_tracks_new_display_order ON tracks_new(display_order);
CREATE INDEX idx_moods_display_order ON moods(display_order);

CREATE INDEX idx_theme_moods_theme_id ON theme_moods(theme_id);
CREATE INDEX idx_theme_moods_mood_id ON theme_moods(mood_id);

CREATE INDEX idx_theme_tracks_theme_id ON theme_tracks(theme_id);
CREATE INDEX idx_theme_tracks_track_id ON theme_tracks(track_id);
CREATE INDEX idx_theme_tracks_display_order ON theme_tracks(theme_id, display_order);

CREATE INDEX idx_track_keywords_track_id ON track_keywords(track_id);
CREATE INDEX idx_track_keywords_keyword_id ON track_keywords(keyword_id);

-- ================================
-- 9. 편의 뷰 생성
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
  array_agg(DISTINCT m.name) as moods,
  array_agg(DISTINCT tr.title) as track_titles,
  count(DISTINCT tr.id) as track_count
FROM themes_new t
LEFT JOIN theme_moods tm ON t.id = tm.theme_id
LEFT JOIN moods m ON tm.mood_id = m.id
LEFT JOIN theme_tracks tt ON t.id = tt.theme_id  
LEFT JOIN tracks_new tr ON tt.track_id = tr.id
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
  array_agg(DISTINCT k.name) as keywords,
  array_agg(DISTINCT th.title) as themes
FROM tracks_new t
LEFT JOIN track_keywords tk ON t.id = tk.track_id
LEFT JOIN keywords k ON tk.keyword_id = k.id
LEFT JOIN theme_tracks tt ON t.id = tt.track_id
LEFT JOIN themes_new th ON tt.theme_id = th.id
GROUP BY t.id, t.code, t.title, t.artist, t.url, t.thumbnail, t.duration_seconds, t.description;

-- ================================
-- 10. 기존 테이블 정리 (나중에 실행)
-- ================================

-- 기존 테이블들을 백업 후 삭제할 수 있도록 rename
-- ALTER TABLE themes RENAME TO themes_backup;
-- ALTER TABLE tracks RENAME TO tracks_backup;

-- 새 테이블을 원래 이름으로 변경
-- ALTER TABLE themes_new RENAME TO themes;
-- ALTER TABLE tracks_new RENAME TO tracks;

-- user_mood_logs 테이블 업데이트 (mood를 ID로 참조하도록)
ALTER TABLE user_mood_logs ADD COLUMN mood_id INTEGER REFERENCES moods(id);

-- 기존 mood 텍스트를 ID로 변환
UPDATE user_mood_logs 
SET mood_id = m.id 
FROM moods m 
WHERE user_mood_logs.mood = m.name;

-- mood 컬럼 제거 예정 (데이터 확인 후)
-- ALTER TABLE user_mood_logs DROP COLUMN mood;