-- 자연음 ASMR 트랙 스펙 업데이트 (E001-E006)
-- 기존 S032-S036 → E001-E006으로 변경
-- 파일명 대문자로 수정 및 새로운 트랙 추가

-- ================================
-- 기존 ASMR 트랙 업데이트 및 새로운 트랙 추가
-- ================================

-- 먼저 기존 S032를 E001으로 업데이트
UPDATE tracks SET 
    code = 'E001',
    title = '새소리(ASMR)',
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/E001_bird_asmr1.mp3',
    file_name = 'E001_bird_asmr1.mp3',
    description = '이른 아침 새들의 인사소리로 하루를 시작해보세요.',
    category = 'ASMR',
    is_asmr = true,
    display_order = 1001
WHERE code = 'S032';

-- 기존 S033-S036 삭제 (새로운 E002-E006으로 대체)
DELETE FROM track_keywords WHERE track_id IN (
    SELECT id FROM tracks WHERE code IN ('S033', 'S034', 'S035', 'S036')
);
DELETE FROM theme_tracks WHERE track_id IN (
    SELECT id FROM tracks WHERE code IN ('S033', 'S034', 'S035', 'S036')
);
DELETE FROM tracks WHERE code IN ('S033', 'S034', 'S035', 'S036');

-- 새로운 ASMR 트랙들 추가
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES 
('E002', '장작불소리(ASMR)', '에브리슬립', 
 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/E002_fire_asmr1.mp3', 
 NULL, 'ASMR', NULL, NULL, 'E002_fire_asmr1.mp3', 
 '벽난로 옆 장작이 타는 소리는 마음이 안정됩니다.', true, 1002),

('E003', '빗소리(ASMR)', '에브리슬립', 
 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/E003_rain_asmr2.mp3', 
 NULL, 'ASMR', NULL, NULL, 'E003_rain_asmr2.mp3', 
 '빗방울 리듬이 마음을 온전하게 만들어줍니다.', true, 1003),

('E004', '물소리(ASMR)', '에브리슬립', 
 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/E004_water_asmr.mp3', 
 NULL, 'ASMR', NULL, NULL, 'E004_water_asmr.mp3', 
 '맑고 투명한 계곡물이 흐르는 숲 속에 귀기울여보세요.', true, 1004),

('E005', '파도소리(ASMR)', '에브리슬립', 
 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/E005_wave_asmr.mp4', 
 NULL, 'ASMR', NULL, NULL, 'E005_wave_asmr.mp4', 
 '시원한 바닷바람과 파도소리로 휴식을 취하세요.', true, 1005),

('E006', '바람소리(ASMR)', '에브리슬립', 
 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/E006_wind_asmr.mp4', 
 NULL, 'ASMR', NULL, NULL, 'E006_wind_asmr.mp4', 
 '시원해지는 숲 속의 바람소리로 마음을 이완시켜보세요.', true, 1006);

-- ================================
-- ASMR 트랙-키워드 관계 설정
-- ================================

-- 모든 ASMR 트랙에 이명케어 키워드 연결
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E001' AND k.name = '이명케어'
ON CONFLICT DO NOTHING;

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E002' AND k.name = '이명케어'
ON CONFLICT DO NOTHING;

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E003' AND k.name = '이명케어'
ON CONFLICT DO NOTHING;

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E004' AND k.name = '이명케어'
ON CONFLICT DO NOTHING;

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E005' AND k.name = '이명케어'
ON CONFLICT DO NOTHING;

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E006' AND k.name = '이명케어'
ON CONFLICT DO NOTHING;

-- ================================
-- 테마-트랙 관계 업데이트 (이명 케어 테마)
-- ================================

-- 기존 S032 관계는 자동으로 E001으로 업데이트됨 (code만 바뀜)
-- 새로운 ASMR 트랙들을 이명 케어 테마에 추가

-- 먼저 기존 theme_tracks에서 S032 참조를 정리 (E001으로 이미 업데이트됨)

-- 새로운 ASMR 트랙들을 이명 케어 테마(theme_03)에 추가
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 2 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'E002'
ON CONFLICT DO NOTHING;

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 3 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'E003'
ON CONFLICT DO NOTHING;

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 4 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'E004'
ON CONFLICT DO NOTHING;

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 5 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'E005'
ON CONFLICT DO NOTHING;

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 6 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'E006'
ON CONFLICT DO NOTHING;

-- E001 (기존 S032)의 테마 내 display_order를 1로 변경
UPDATE theme_tracks 
SET display_order = 1 
WHERE theme_id = (SELECT id FROM themes WHERE code = 'theme_03') 
  AND track_id = (SELECT id FROM tracks WHERE code = 'E001');

-- ================================
-- 데이터 정합성 검증
-- ================================

-- 모든 ASMR 트랙 확인 (E001-E006)
SELECT 
    code,
    title,
    url,
    file_name,
    category,
    is_asmr,
    display_order
FROM tracks 
WHERE code LIKE 'E%'
ORDER BY code;

-- 이명 케어 테마의 트랙 확인
SELECT 
    t.title as theme_title,
    tr.code,
    tr.title as track_title,
    tt.display_order
FROM themes t
JOIN theme_tracks tt ON t.id = tt.theme_id
JOIN tracks tr ON tt.track_id = tr.id
WHERE t.code = 'theme_03'
ORDER BY tt.display_order;

-- 전체 트랙 수 확인
SELECT 
    COUNT(*) as total_tracks,
    COUNT(CASE WHEN is_asmr = true THEN 1 END) as asmr_tracks,
    COUNT(CASE WHEN code LIKE 'S%' THEN 1 END) as music_tracks,
    COUNT(CASE WHEN code LIKE 'E%' THEN 1 END) as environment_tracks
FROM tracks;