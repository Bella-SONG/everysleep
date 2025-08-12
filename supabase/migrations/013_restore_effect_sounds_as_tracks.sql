-- Restore E001-E006 effect sounds as actual tracks
-- These will serve dual purpose: effects in player + tracks in theme playlists

-- Add E001-E006 back to tracks table with correct effects folder URLs
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('E001', '새소리(ASMR)', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/effects/E001_BIRD ASMR1.mp3', NULL, '자연음', NULL, NULL, 'E001_BIRD ASMR1.mp3', '이른 아침 새들의 인사소리로 하루를 시작해보세요.', true, 1001);

INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('E002', '장작불소리(ASMR)', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/effects/E002_FIRE ASMR.mp3', NULL, '자연음', NULL, NULL, 'E002_FIRE ASMR.mp3', '벽난로 옆 장작이 타는 소리는 마음이 안정됩니다.', true, 1002);

INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('E003', '빗소리(ASMR)', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/effects/E003_RAIN ASMR2.mp3', NULL, '자연음', NULL, NULL, 'E003_RAIN ASMR2.mp3', '빗방울 리듬이 마음을 온전하게 만들어줍니다.', true, 1003);

INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('E004', '파도소리(ASMR)', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/effects/E004_WAVE ASMR.mp3', NULL, '자연음', NULL, NULL, 'E004_WAVE ASMR.mp3', '시원한 바닷바람과 파도소리로 휴식을 취하세요.', true, 1004);

INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('E005', '물소리(ASMR)', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/effects/E005_WATER ASMR.mp3', NULL, '자연음', NULL, NULL, 'E005_WATER ASMR.mp3', '맑고 투명한 계곡물이 흐르는 숲 속에 귀기울여보세요.', true, 1005);

INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('E006', '바람소리(ASMR)', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/effects/E006_WIND ASMR.mp3', NULL, '자연음', NULL, NULL, 'E006_WIND ASMR.mp3', '시원해지는 숲 속의 바람소리로 마음을 이완시켜보세요.', true, 1006);

-- Re-establish theme-track relationships for tinnitus care theme
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 2 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'E001';

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 3 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'E002';

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 4 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'E003';

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 5 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'E004';

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 6 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'E005';

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 7 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'E006';

-- Add keywords for these tracks
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E001' AND k.name = '이명케어';

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E002' AND k.name = '이명케어';

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E003' AND k.name = '이명케어';

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E004' AND k.name = '이명케어';

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E005' AND k.name = '이명케어';

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'E006' AND k.name = '이명케어';