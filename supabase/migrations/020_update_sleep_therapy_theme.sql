-- 숙면테라피 테마 트랙 구성 업데이트
-- S008(track_id: 8), S010(track_id: 10)을 S006(track_id: 6), S009(track_id: 9)로 교체

-- 기존 S008, S010 매핑 삭제
DELETE FROM theme_tracks 
WHERE theme_id = 1 
AND track_id IN (8, 10);

-- S006, S009 추가
INSERT INTO theme_tracks (theme_id, track_id, display_order)
VALUES
    (1, 6, 3),   -- S008 자리에 S006 (마음을 다독이며)
    (1, 9, 4);   -- S010 자리에 S009 (여름의 마음)

-- 최종 숙면테라피 테마 구성 (8곡):
-- S001: 가장 행복한 꿈 (display_order: 1)
-- S007: 별빛이 남긴 추억 (display_order: 2) 
-- S006: 마음을 다독이며 (display_order: 3)
-- S009: 여름의 마음 (display_order: 4)
-- S013: 선선한 봄날의 기억 (display_order: 5)
-- S014: 아름다운 쉼표 (display_order: 6)
-- S016: 어른들의 자장가 (display_order: 7)
-- S030: 희망의 빛을 따라서 (display_order: 8)