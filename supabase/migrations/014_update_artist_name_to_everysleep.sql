-- 아티스트명을 "에브리슬립"에서 "everysleep"으로 변경
-- 모든 트랙의 artist 필드 업데이트

UPDATE tracks 
SET artist = 'everysleep' 
WHERE artist = '에브리슬립';

-- 업데이트된 레코드 수 확인 (디버그용)
-- 이 쿼리는 실제로는 실행되지 않지만 참고용으로 남겨둠
-- SELECT COUNT(*) as updated_count FROM tracks WHERE artist = 'everysleep';