-- 테마별 어울리는 이미지 업데이트
-- Unsplash 고품질 무료 이미지 사용

-- 1. 테마 이미지 업데이트
UPDATE themes SET icon_path = CASE
    -- 자연소리 테마들
    WHEN title LIKE '%빗소리%' OR title LIKE '%비%' THEN 
        'https://images.unsplash.com/photo-1519692933481-e162a57d6721?w=800&q=80' -- 창문에 떨어지는 빗방울
    
    WHEN title LIKE '%파도%' OR title LIKE '%바다%' THEN 
        'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=800&q=80' -- 고요한 바다 파도
    
    WHEN title LIKE '%숲%' OR title LIKE '%산림%' THEN 
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80' -- 평화로운 숲길
    
    WHEN title LIKE '%시골%' OR title LIKE '%농촌%' THEN 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80' -- 평화로운 시골 풍경
    
    WHEN title LIKE '%새소리%' OR title LIKE '%새%' THEN 
        'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=800&q=80' -- 아침 새들
    
    -- 휴식/수면 테마들
    WHEN title LIKE '%수면%' OR title LIKE '%잠%' OR title LIKE '%숙면%' THEN 
        'https://images.unsplash.com/photo-1531353826977-0941b4779a1c?w=800&q=80' -- 평화로운 침실
    
    WHEN title LIKE '%명상%' OR title LIKE '%요가%' THEN 
        'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800&q=80' -- 일출 명상
    
    WHEN title LIKE '%휴식%' OR title LIKE '%안정%' THEN 
        'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=800&q=80' -- 편안한 휴식 공간
    
    -- 기본 이미지 (매칭되지 않는 경우)
    ELSE 'https://images.unsplash.com/photo-1487260211189-670c54da558d?w=800&q=80' -- 평화로운 풍경
END
WHERE icon_path IS NULL OR icon_path = '';

-- 2. 트랙 이미지 업데이트
-- 모든 트랙 코드별 1:1 매핑 (sample_data.dart 기준)
UPDATE tracks SET thumbnail = CASE
    -- S001-S031 음악 트랙들 (sample_data.dart에서 사용하는 이미지 그대로 사용)
    WHEN code = 'S001' THEN 'assets/images/wolf-zimmermann-6sf5rf8QYFE-unsplash.jpg' -- 가장 행복한 꿈
    WHEN code = 'S002' THEN 'assets/images/thankyou.jpg' -- 감사의 일기
    WHEN code = 'S003' THEN 'assets/images/re2.jpg' -- 다정한 휴식
    WHEN code = 'S004' THEN 'assets/images/f1.jpg' -- 들꽃처럼 피어나는 희망
    WHEN code = 'S005' THEN 'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?w=300&h=300&fit=crop' -- 따스한 봄날의 노래
    WHEN code = 'S006' THEN 'assets/images/giulia-bertelli-dvXGnwnYweM-unsplash.jpg' -- 마음을 다독이며
    WHEN code = 'S007' THEN 'assets/images/marek-piwnicki-iwabZE-qN_U-unsplash.jpg' -- 별빛이 남긴 추억
    WHEN code = 'S008' THEN 'https://images.unsplash.com/photo-1545221167-d3fba6820656?w=300&h=300&fit=crop' -- 비오는 경복궁 돌담길
    WHEN code = 'S009' THEN 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=300&h=300&fit=crop' -- 여름의 마음
    WHEN code = 'S010' THEN 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=300&h=300&fit=crop' -- 여름의 마음 (ASMR)
    WHEN code = 'S011' THEN 'https://images.unsplash.com/photo-1501436513145-30f24e19fcc4?w=300&h=300&fit=crop' -- 빗소리에 눈을 뜬 아침
    WHEN code = 'S012' THEN 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=300&h=300&fit=crop' -- 빗소리와 책장을 넘기며
    WHEN code = 'S013' THEN 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=300&h=300&fit=crop' -- 선선한 봄날의 기억
    WHEN code = 'S014' THEN 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=300&fit=crop' -- 아름다운 쉼표
    WHEN code = 'S015' THEN 'https://images.unsplash.com/photo-1516905365441-80295fccd862?w=300&h=300&fit=crop' -- 쉼이있는 순간
    WHEN code = 'S016' THEN 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=300&h=300&fit=crop' -- 어른들의 자장가
    WHEN code = 'S017' THEN 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=300&fit=crop' -- 오늘도 수고했어요
    WHEN code = 'S018' THEN 'assets/images/c2.jpg' -- 좋은 꿈을 꿀거예요
    WHEN code = 'S019' THEN 'assets/images/f3.jpg' -- 평화로운 나의 아침
    WHEN code = 'S020' THEN 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=300&h=300&fit=crop' -- 푸르른 공원 산책
    WHEN code = 'S021' THEN 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=300&h=300&fit=crop' -- 푸르른 공원 산책 (ASMR)
    WHEN code = 'S022' THEN 'assets/images/f4.jpg' -- 햇살 가득한 하루
    WHEN code = 'S023' THEN 'assets/images/f4.jpg' -- 햇살 가득한 하루 (ASMR)
    WHEN code = 'S024' THEN 'assets/images/shche_-team-0dszrg9-V1o-unsplash.jpg' -- 행복이 있는 식탁
    WHEN code = 'S025' THEN 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=300&h=300&fit=crop' -- 흰나비의 날갯짓
    WHEN code = 'S026' THEN 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=300&h=300&fit=crop' -- 비 내리는 창가에 앉아
    WHEN code = 'S027' THEN 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=300&h=300&fit=crop' -- 매일 더 사랑
    WHEN code = 'S028' THEN 'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=300&h=300&fit=crop' -- 벚꽃이 휘날리던 날
    WHEN code = 'S029' THEN 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=300&h=300&fit=crop' -- 행복의 봄
    WHEN code = 'S030' THEN 'assets/images/wolf-zimmermann-6sf5rf8QYFE-unsplash.jpg' -- 희망의 빛을 따라서
    WHEN code = 'S031' THEN 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=300&h=300&fit=crop' -- 재즈 레스토랑
    
    -- E001-E006 자연음 트랙들 (sample_data.dart에서 사용하는 이미지 그대로 사용)
    WHEN code = 'E001' THEN 'assets/images/bird.jpg' -- 새소리(ASMR)
    WHEN code = 'E002' THEN 'assets/images/fire.jpg' -- 장작불소리(ASMR)
    WHEN code = 'E003' THEN 'https://images.unsplash.com/photo-1428592953211-077101b2021b?w=300&h=300&fit=crop' -- 빗소리(ASMR)
    WHEN code = 'E004' THEN 'assets/images/water.jpg' -- 물소리(ASMR)
    WHEN code = 'E005' THEN 'assets/images/wave.jpg' -- 파도소리(ASMR)
    WHEN code = 'E006' THEN 'assets/images/wind.jpg' -- 바람소리(ASMR)
    
    -- 기타 트랙들은 기본 이미지 사용
    ELSE 'assets/images/sleep1.png'
END;

-- 3. 특별히 이명(tinnitus) 관련 테마는 부드러운 자연 이미지로
UPDATE themes 
SET icon_path = 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800&q=80' -- 고요한 물결
WHERE id IN (
    SELECT DISTINCT t.id
    FROM themes t
    JOIN theme_moods tm ON t.id = tm.theme_id
    JOIN moods m ON tm.mood_id = m.id
    WHERE m.name = '귀에서 소리가 나요'
);

-- 4. 시니어 친화적인 이미지로 업데이트 (너무 복잡하지 않고 선명한 이미지)
-- 특별히 인기있는 테마들은 더 밝고 친근한 이미지로
UPDATE themes 
SET icon_path = CASE
    WHEN title = '편안한 빗소리' THEN 
        'https://images.unsplash.com/photo-1556075798-4825dfaaf498?w=800&q=80' -- 창가 빗소리
    WHEN title = '고요한 바다' THEN 
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80' -- 맑은 바다
    WHEN title = '깊은 숲속' THEN 
        'https://images.unsplash.com/photo-1511497584788-876760111969?w=800&q=80' -- 햇살 비치는 숲
    ELSE icon_path
END
WHERE title IN ('편안한 빗소리', '고요한 바다', '깊은 숲속');

-- 5. 실행 후 확인
SELECT 'Themes with images:' as info, COUNT(*) as count 
FROM themes 
WHERE icon_path IS NOT NULL AND icon_path != '';

SELECT 'Tracks with images:' as info, COUNT(*) as count 
FROM tracks 
WHERE thumbnail IS NOT NULL AND thumbnail != '';