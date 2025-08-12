-- 이명("귀에서 소리가 나요")에 매핑된 테마와 트랙 확인

-- 1. 먼저 "귀에서 소리가 나요" 기분의 ID 확인
SELECT id, name, emoji, description 
FROM moods 
WHERE name = '귀에서 소리가 나요';

-- 2. 이명과 매핑된 테마들 확인
SELECT 
    m.name as mood_name,
    t.id as theme_id,
    t.title as theme_title,
    t.subtitle as theme_subtitle,
    t.description as theme_description
FROM moods m
JOIN theme_moods tm ON m.id = tm.mood_id
JOIN themes t ON tm.theme_id = t.id
WHERE m.name = '귀에서 소리가 나요'
ORDER BY t.display_order;

-- 3. 이명과 매핑된 테마들의 트랙 확인
SELECT 
    m.name as mood_name,
    t.title as theme_title,
    tr.title as track_title,
    tr.artist,
    tr.category,
    tr.is_asmr,
    tr.description
FROM moods m
JOIN theme_moods tm ON m.id = tm.mood_id
JOIN themes t ON tm.theme_id = t.id
JOIN theme_tracks tt ON t.id = tt.theme_id
JOIN tracks tr ON tt.track_id = tr.id
WHERE m.name = '귀에서 소리가 나요'
ORDER BY t.display_order, tt.display_order;

-- 4. "재즈레스토랑" 테마가 어떤 기분들과 매핑되어 있는지 확인
SELECT 
    t.title as theme_title,
    m.name as mood_name,
    m.emoji,
    m.description as mood_description
FROM themes t
JOIN theme_moods tm ON t.id = tm.theme_id
JOIN moods m ON tm.mood_id = m.id
WHERE t.title ILIKE '%재즈%' OR t.title ILIKE '%jazz%' OR t.title ILIKE '%레스토랑%'
ORDER BY t.title, m.display_order;

-- 5. 모든 테마 제목 확인 (재즈 관련 찾기)
SELECT id, title, subtitle, description
FROM themes
WHERE title ILIKE '%재즈%' OR title ILIKE '%jazz%' OR title ILIKE '%레스토랑%' OR subtitle ILIKE '%재즈%' OR subtitle ILIKE '%jazz%';