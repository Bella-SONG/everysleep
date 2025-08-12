-- 실제 Supabase 스토리지 URL로 tracks 테이블 업데이트
-- 기존: https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/
-- 신규: https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/

-- ================================
-- Tracks 테이블 URL 업데이트
-- ================================

-- S001-S031 음악 트랙 URL 업데이트
UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S001_happiest_dream.mp3',
    file_name = 'S001_happiest_dream.mp3'
WHERE code = 'S001';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S002_thanks_diary.mp3',
    file_name = 'S002_thanks_diary.mp3'
WHERE code = 'S002';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S003_gentle_jazz.mp3',
    file_name = 'S003_gentle_jazz.mp3'
WHERE code = 'S003';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S004_hope_flower.mp3',
    file_name = 'S004_hope_flower.mp3'
WHERE code = 'S004';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S005_warm_spring_song.mp3',
    file_name = 'S005_warm_spring_song.mp3'
WHERE code = 'S005';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S006_soothing_heart.mp3',
    file_name = 'S006_soothing_heart.mp3'
WHERE code = 'S006';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S007_star_memory.mp3',
    file_name = 'S007_star_memory.mp3'
WHERE code = 'S007';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S008_rainy_gyeongbokgu.mp3',
    file_name = 'S008_rainy_gyeongbokgu.mp3'
WHERE code = 'S008';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S009_heart_summer.mp3',
    file_name = 'S009_heart_summer.mp3'
WHERE code = 'S009';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S010_heart_summer_asmr.mp3',
    file_name = 'S010_heart_summer_asmr.mp3'
WHERE code = 'S010';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S011_morning_awake_asm.mp3',
    file_name = 'S011_morning_awake_asm.mp3'
WHERE code = 'S011';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S012_book_pages_asmr.m.mp3',
    file_name = 'S012_book_pages_asmr.m.mp3'
WHERE code = 'S012';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S013_spring_memory.mp3',
    file_name = 'S013_spring_memory.mp3'
WHERE code = 'S013';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S014_beautiful_comma.mp3',
    file_name = 'S014_beautiful_comma.mp3'
WHERE code = 'S014';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S015_moment_rest.mp3',
    file_name = 'S015_moment_rest.mp3'
WHERE code = 'S015';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S016_adults_lullaby.mp3',
    file_name = 'S016_adults_lullaby.mp3'
WHERE code = 'S016';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S017_well_today.mp3',
    file_name = 'S017_well_today.mp3'
WHERE code = 'S017';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S018_have_good_dream.mp3',
    file_name = 'S018_have_good_dream.mp3'
WHERE code = 'S018';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S019_peaceful_morning.mp3',
    file_name = 'S019_peaceful_morning.mp3'
WHERE code = 'S019';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S020_park_walk.mp3',
    file_name = 'S020_park_walk.mp3'
WHERE code = 'S020';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S021_park_walk_asmr.mp3',
    file_name = 'S021_park_walk_asmr.mp3'
WHERE code = 'S021';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S022_sunshine_day.mp3',
    file_name = 'S022_sunshine_day.mp3'
WHERE code = 'S022';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S023_sunshine_day_asmr.mp3',
    file_name = 'S023_sunshine_day_asmr.mp3'
WHERE code = 'S023';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S024_happy_table.mp3',
    file_name = 'S024_happy_table.mp3'
WHERE code = 'S024';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S025_butterfly_wings.mp3',
    file_name = 'S025_butterfly_wings.mp3'
WHERE code = 'S025';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S026_rainy_chill.mp3',
    file_name = 'S026_rainy_chill.mp3',
    title = '비 내리는 창가에 앉아'
WHERE code = 'S026';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S027_more_love.mp3',
    file_name = 'S027_more_love.mp3'
WHERE code = 'S027';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S028_day_blossom.mp3',
    file_name = 'S028_day_blossom.mp3'
WHERE code = 'S028';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S029_happy_spring.mp3',
    file_name = 'S029_happy_spring.mp3',
    title = '행복의 봄'
WHERE code = 'S029';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S030_following_hope.mp3',
    file_name = 'S030_following_hope.mp3'
WHERE code = 'S030';

UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S031_jazz_restaurant.mp3',
    file_name = 'S031_jazz_restaurant.mp3'
WHERE code = 'S031';

-- S032 ASMR 트랙 URL 업데이트 
UPDATE tracks SET 
    url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S032_bird_asmr1.mp3',
    file_name = 'S032_bird_asmr1.mp3',
    is_asmr = true,
    category = 'ASMR'
WHERE code = 'S032';

-- ================================
-- 데이터 정합성 검증
-- ================================

-- 업데이트된 URL 확인
SELECT 
    code,
    title,
    url,
    file_name,
    category,
    is_asmr
FROM tracks 
ORDER BY CAST(SUBSTRING(code FROM 2) AS INTEGER);

-- ASMR 트랙 확인
SELECT 
    code,
    title,
    category,
    is_asmr
FROM tracks 
WHERE is_asmr = true OR category = 'ASMR'
ORDER BY code;