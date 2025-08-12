-- ASMR 트랙들의 제목 수정 (제목에 ASMR 표시 추가)
UPDATE tracks SET title = CASE
    WHEN code = 'S010' THEN '여름의 마음 (ASMR)'
    WHEN code = 'S021' THEN '푸르른 공원 산책 (ASMR)'  
    WHEN code = 'S023' THEN '햇살 가득한 하루 (ASMR)'
    ELSE title
END
WHERE code IN ('S010', 'S021', 'S023') AND is_asmr = true;

-- 자연음 ASMR 트랙들도 확인 (E001-E006)
UPDATE tracks SET title = CASE
    WHEN code = 'E001' THEN '새소리(ASMR)'
    WHEN code = 'E002' THEN '장작불소리(ASMR)'
    WHEN code = 'E003' THEN '빗소리(ASMR)'
    WHEN code = 'E004' THEN '물소리(ASMR)'
    WHEN code = 'E005' THEN '파도소리(ASMR)'
    WHEN code = 'E006' THEN '바람소리(ASMR)'
    ELSE title
END
WHERE code IN ('E001', 'E002', 'E003', 'E004', 'E005', 'E006');

-- 실행 후 확인
SELECT code, title, is_asmr 
FROM tracks 
WHERE is_asmr = true OR code IN ('S009', 'S020', 'S022')
ORDER BY code;