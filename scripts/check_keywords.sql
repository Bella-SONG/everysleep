-- track_details 뷰에서 키워드 확인
SELECT code, title, keywords
FROM track_details 
WHERE code IN ('S001', 'S002', 'S003', 'S004', 'S022', 'S023')
ORDER BY code;

-- 키워드별 트랙 개수 확인  
SELECT '수면' as keyword, COUNT(*) as track_count
FROM track_details 
WHERE keywords @> '[{"name": "수면"}]'

UNION ALL

SELECT '이완' as keyword, COUNT(*) as track_count  
FROM track_details
WHERE keywords @> '[{"name": "이완"}]'

UNION ALL

SELECT '활력' as keyword, COUNT(*) as track_count
FROM track_details  
WHERE keywords @> '[{"name": "활력"}]'

ORDER BY keyword;