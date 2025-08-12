-- 누락된 ASMR 트랙 추가 (S033-S036)
-- 실제 업로드 예정인 ASMR 트랙들을 데이터베이스에 추가

-- ================================
-- 누락된 ASMR 트랙 추가
-- ================================

-- 먼저 기존 S033-S036이 있는지 확인하고 있다면 URL만 업데이트
DO $$
DECLARE
    track_exists boolean;
BEGIN
    -- S033 체크 및 추가
    SELECT EXISTS(SELECT 1 FROM tracks WHERE code = 'S033') INTO track_exists;
    IF track_exists THEN
        UPDATE tracks SET 
            url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S033_fire_asmr.mp3',
            file_name = 'S033_fire_asmr.mp3',
            is_asmr = true,
            category = 'ASMR'
        WHERE code = 'S033';
    ELSE
        INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
        VALUES ('S033', '장작불소리(ASMR)', '에브리슬립', 
                'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S033_fire_asmr.mp3', 
                NULL, 'ASMR', NULL, NULL, 'S033_fire_asmr.mp3', 
                '벽난로 옆 장작이 타는 소리는 마음이 안정됩니다.', true, 33);
    END IF;

    -- S034 체크 및 추가
    SELECT EXISTS(SELECT 1 FROM tracks WHERE code = 'S034') INTO track_exists;
    IF track_exists THEN
        UPDATE tracks SET 
            url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S034_rain_asmr.mp3',
            file_name = 'S034_rain_asmr.mp3',
            is_asmr = true,
            category = 'ASMR'
        WHERE code = 'S034';
    ELSE
        INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
        VALUES ('S034', '빗소리(ASMR)', '에브리슬립', 
                'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S034_rain_asmr.mp3', 
                NULL, 'ASMR', NULL, NULL, 'S034_rain_asmr.mp3', 
                '빗방울 리듬이 마음을 온전하게 만들어줍니다.', true, 34);
    END IF;

    -- S035 체크 및 추가
    SELECT EXISTS(SELECT 1 FROM tracks WHERE code = 'S035') INTO track_exists;
    IF track_exists THEN
        UPDATE tracks SET 
            url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S035_wave_asmr.mp3',
            file_name = 'S035_wave_asmr.mp3',
            is_asmr = true,
            category = 'ASMR'
        WHERE code = 'S035';
    ELSE
        INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
        VALUES ('S035', '파도소리(ASMR)', '에브리슬립', 
                'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S035_wave_asmr.mp3', 
                NULL, 'ASMR', NULL, NULL, 'S035_wave_asmr.mp3', 
                '시원한 바닷바람과 파도소리로 휴식을 취하세요.', true, 35);
    END IF;

    -- S036 체크 및 추가
    SELECT EXISTS(SELECT 1 FROM tracks WHERE code = 'S036') INTO track_exists;
    IF track_exists THEN
        UPDATE tracks SET 
            url = 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S036_water_asmr.mp3',
            file_name = 'S036_water_asmr.mp3',
            is_asmr = true,
            category = 'ASMR'
        WHERE code = 'S036';
    ELSE
        INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
        VALUES ('S036', '물소리(ASMR)', '에브리슬립', 
                'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/everysleeptrack/tracks/S036_water_asmr.mp3', 
                NULL, 'ASMR', NULL, NULL, 'S036_water_asmr.mp3', 
                '맑고 투명한 계곡물이 흐르는 숲 속에 귀기울여보세요.', true, 36);
    END IF;
END $$;

-- ================================
-- ASMR 트랙에 대한 키워드 매핑 추가
-- ================================

-- 이명케어 키워드와 ASMR 트랙 매핑
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S033' AND k.name = '이명케어'
ON CONFLICT DO NOTHING;

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S034' AND k.name = '이명케어'
ON CONFLICT DO NOTHING;

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S035' AND k.name = '이명케어'
ON CONFLICT DO NOTHING;

INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S036' AND k.name = '이명케어'
ON CONFLICT DO NOTHING;

-- ================================
-- 테마-트랙 관계에 ASMR 트랙 추가 (이명 케어 테마)
-- ================================

-- 이명 케어 테마에 새로운 ASMR 트랙들 추가
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 7 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'S033'
ON CONFLICT DO NOTHING;

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 8 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'S034'
ON CONFLICT DO NOTHING;

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 9 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'S035'
ON CONFLICT DO NOTHING;

INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 10 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'S036'
ON CONFLICT DO NOTHING;

-- ================================
-- 데이터 정합성 검증
-- ================================

-- 모든 ASMR 트랙 확인
SELECT 
    code,
    title,
    url,
    category,
    is_asmr,
    display_order
FROM tracks 
WHERE is_asmr = true OR category = 'ASMR'
ORDER BY CAST(SUBSTRING(code FROM 2) AS INTEGER);

-- 이명 케어 테마의 트랙 수 확인
SELECT 
    t.title as theme_title,
    COUNT(tt.track_id) as track_count
FROM themes t
LEFT JOIN theme_tracks tt ON t.id = tt.theme_id
WHERE t.code = 'theme_03'
GROUP BY t.id, t.title;

-- 전체 트랙 수 확인
SELECT 
    COUNT(*) as total_tracks,
    COUNT(CASE WHEN is_asmr = true THEN 1 END) as asmr_tracks,
    COUNT(CASE WHEN category = 'ASMR' THEN 1 END) as asmr_category_tracks
FROM tracks;