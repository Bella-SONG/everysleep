-- 이명과 재즈레스토랑 매핑 문제 디버깅

-- 1. "귀에서 소리가 나요" 기분 ID 확인
SELECT id, name, emoji 
FROM moods 
WHERE name = '귀에서 소리가 나요';

-- 2. "재즈" 관련 테마들 찾기
SELECT id, title, subtitle, description
FROM themes
WHERE title ILIKE '%재즈%' 
   OR title ILIKE '%jazz%' 
   OR subtitle ILIKE '%재즈%' 
   OR subtitle ILIKE '%jazz%'
   OR title ILIKE '%레스토랑%'
   OR subtitle ILIKE '%레스토랑%';

-- 3. 이명 기분과 매핑된 모든 테마들
SELECT 
    m.id as mood_id,
    m.name as mood_name,
    t.id as theme_id,
    t.title as theme_title,
    t.subtitle as theme_subtitle
FROM moods m
JOIN theme_moods tm ON m.id = tm.mood_id
JOIN themes t ON tm.theme_id = t.id
WHERE m.name = '귀에서 소리가 나요'
ORDER BY t.id;

-- 4. 재즈 관련 테마가 어떤 기분들과 매핑되어 있는지
SELECT 
    t.id as theme_id,
    t.title as theme_title,
    m.id as mood_id,
    m.name as mood_name
FROM themes t
JOIN theme_moods tm ON t.id = tm.theme_id
JOIN moods m ON tm.mood_id = m.id
WHERE (t.title ILIKE '%재즈%' 
    OR t.title ILIKE '%jazz%' 
    OR t.title ILIKE '%레스토랑%')
ORDER BY t.id, m.id;

-- 5. 잘못된 매핑 제거용 쿼리 (실행 전 확인용)
-- DELETE FROM theme_moods 
-- WHERE mood_id = (SELECT id FROM moods WHERE name = '귀에서 소리가 나요')
--   AND theme_id IN (
--     SELECT id FROM themes 
--     WHERE title ILIKE '%재즈%' 
--        OR title ILIKE '%jazz%' 
--        OR title ILIKE '%레스토랑%'
--   );

-- 6. 이명에 적합한 테마들 확인 (자연소리, 화이트노이즈 등)
SELECT 
    t.id,
    t.title,
    t.subtitle,
    tr.title as track_title,
    tr.category,
    CASE 
        WHEN tr.title ILIKE '%빗소리%' OR tr.title ILIKE '%비%' THEN '적합'
        WHEN tr.title ILIKE '%파도%' OR tr.title ILIKE '%바다%' THEN '적합'
        WHEN tr.title ILIKE '%화이트%' OR tr.title ILIKE '%노이즈%' THEN '적합'
        WHEN tr.title ILIKE '%재즈%' OR tr.title ILIKE '%피아노%' THEN '부적합'
        WHEN tr.title ILIKE '%음악%' THEN '부적합'
        ELSE '확인필요'
    END as 이명적합성
FROM themes t
JOIN theme_tracks tt ON t.id = tt.theme_id
JOIN tracks tr ON tt.track_id = tr.id
JOIN theme_moods tm ON t.id = tm.theme_id
JOIN moods m ON tm.mood_id = m.id
WHERE m.name = '귀에서 소리가 나요'
ORDER BY t.id, tt.display_order;