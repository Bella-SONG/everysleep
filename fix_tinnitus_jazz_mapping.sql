-- 이명용 테마에서 재즈 트랙 제거

-- 1. 먼저 현재 매핑 상태 확인
SELECT 
    t.id as theme_id,
    t.title as theme_title,
    tr.id as track_id,
    tr.code as track_code,
    tr.title as track_title,
    tr.category,
    tt.display_order
FROM themes t
JOIN theme_tracks tt ON t.id = tt.theme_id
JOIN tracks tr ON tt.track_id = tr.id
WHERE t.id IN (3, 6) 
  AND tr.code = 'S031'
ORDER BY t.id, tt.display_order;

-- 2. S031 트랙 정보 확인
SELECT id, code, title, artist, category, description, is_asmr
FROM tracks 
WHERE code = 'S031';

-- 3. 테마 3, 6이 어떤 기분과 연결되어 있는지 확인
SELECT 
    t.id as theme_id,
    t.title as theme_title,
    m.id as mood_id,
    m.name as mood_name
FROM themes t
JOIN theme_moods tm ON t.id = tm.theme_id
JOIN moods m ON tm.mood_id = m.id
WHERE t.id IN (3, 6)
ORDER BY t.id;

-- 4. 잘못된 매핑 제거 (재즈 트랙을 이명용 테마에서 제거)
-- 실행 전 위의 쿼리들로 확인 후 실행하세요
DELETE FROM theme_tracks 
WHERE theme_id IN (3, 6) 
  AND track_id = (SELECT id FROM tracks WHERE code = 'S031');

-- 5. 제거 후 확인
SELECT 
    t.id as theme_id,
    t.title as theme_title,
    COUNT(tt.track_id) as track_count,
    string_agg(tr.title, ', ' ORDER BY tt.display_order) as remaining_tracks
FROM themes t
LEFT JOIN theme_tracks tt ON t.id = tt.theme_id
LEFT JOIN tracks tr ON tt.track_id = tr.id
WHERE t.id IN (3, 6)
GROUP BY t.id, t.title
ORDER BY t.id;