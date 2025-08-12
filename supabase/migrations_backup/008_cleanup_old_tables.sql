-- 기존 테이블 정리 및 새 테이블 이름 변경
-- 정규화 완료 후 불필요한 테이블 제거

-- ================================
-- 1. 새 테이블을 원래 이름으로 변경
-- ================================

-- 기존 테이블 백업 후 삭제
DROP TABLE IF EXISTS themes CASCADE;
DROP TABLE IF EXISTS tracks CASCADE;

-- 새 테이블을 원래 이름으로 변경
ALTER TABLE themes_new RENAME TO themes;
ALTER TABLE tracks_new RENAME TO tracks;

-- ================================
-- 2. 인덱스 이름 업데이트
-- ================================

-- themes 테이블 인덱스
DROP INDEX IF EXISTS idx_themes_new_display_order;
CREATE INDEX idx_themes_display_order ON themes(display_order);

-- tracks 테이블 인덱스  
DROP INDEX IF EXISTS idx_tracks_new_display_order;
CREATE INDEX idx_tracks_display_order ON tracks(display_order);

-- ================================
-- 3. 외래키 제약조건 업데이트
-- ================================

-- theme_tracks 테이블의 외래키 업데이트
ALTER TABLE theme_tracks DROP CONSTRAINT IF EXISTS theme_tracks_theme_id_fkey;
ALTER TABLE theme_tracks ADD CONSTRAINT theme_tracks_theme_id_fkey 
  FOREIGN KEY (theme_id) REFERENCES themes(id) ON DELETE CASCADE;

-- theme_tracks 테이블의 외래키 업데이트  
ALTER TABLE theme_tracks DROP CONSTRAINT IF EXISTS theme_tracks_track_id_fkey;
ALTER TABLE theme_tracks ADD CONSTRAINT theme_tracks_track_id_fkey 
  FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE;

-- track_keywords 테이블의 외래키 업데이트
ALTER TABLE track_keywords DROP CONSTRAINT IF EXISTS track_keywords_track_id_fkey;
ALTER TABLE track_keywords ADD CONSTRAINT track_keywords_track_id_fkey 
  FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE;

-- ================================
-- 4. 뷰 업데이트
-- ================================

-- theme_details 뷰 재생성
DROP VIEW IF EXISTS theme_details;
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
FROM themes t
LEFT JOIN theme_moods tm ON t.id = tm.theme_id
LEFT JOIN moods m ON tm.mood_id = m.id
LEFT JOIN theme_tracks tt ON t.id = tt.theme_id  
LEFT JOIN tracks tr ON tt.track_id = tr.id
GROUP BY t.id, t.code, t.title, t.subtitle, t.description, t.display_order;

-- track_details 뷰 재생성
DROP VIEW IF EXISTS track_details;
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
FROM tracks t
LEFT JOIN track_keywords tk ON t.id = tk.track_id
LEFT JOIN keywords k ON tk.keyword_id = k.id
LEFT JOIN theme_tracks tt ON t.id = tt.track_id
LEFT JOIN themes th ON tt.theme_id = th.id
GROUP BY t.id, t.code, t.title, t.artist, t.url, t.thumbnail, t.duration_seconds, t.description;

-- ================================
-- 5. user_mood_logs 테이블 정리
-- ================================

-- 기존 mood 컬럼 제거 (mood_id로 대체됨)
ALTER TABLE user_mood_logs DROP COLUMN IF EXISTS mood;

-- selected_theme_id 참조를 새로운 themes 테이블로 업데이트
ALTER TABLE user_mood_logs DROP CONSTRAINT IF EXISTS user_mood_logs_selected_theme_id_fkey;
-- 정수형 ID로 변경 필요하므로 일단 제약조건만 제거하고 나중에 처리