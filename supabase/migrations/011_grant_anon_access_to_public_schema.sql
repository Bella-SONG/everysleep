-- anon 역할에 public 스키마 접근 권한 부여
-- "permission denied for schema public" 오류 해결

-- ============================= SCHEMA 권한 부여 =============================

-- anon 역할에 public 스키마 사용 권한 부여
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;

-- ============================= 테이블 권한 부여 =============================

-- anon 역할에 공개 데이터 테이블 읽기 권한 부여
GRANT SELECT ON moods TO anon;
GRANT SELECT ON themes TO anon;
GRANT SELECT ON tracks TO anon;
GRANT SELECT ON keywords TO anon;
GRANT SELECT ON theme_moods TO anon;
GRANT SELECT ON theme_tracks TO anon;
GRANT SELECT ON track_keywords TO anon;

-- authenticated 역할에도 같은 권한 부여
GRANT SELECT ON moods TO authenticated;
GRANT SELECT ON themes TO authenticated;
GRANT SELECT ON tracks TO authenticated;
GRANT SELECT ON keywords TO authenticated;
GRANT SELECT ON theme_moods TO authenticated;
GRANT SELECT ON theme_tracks TO authenticated;
GRANT SELECT ON track_keywords TO authenticated;

-- ============================= 시퀀스 권한 부여 =============================

-- ID 생성을 위한 시퀀스 사용 권한
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ============================= 함수 권한 부여 =============================

-- 공개 함수 실행 권한 (필요시)
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

-- ============================= 권한 확인 =============================

-- 권한 확인 쿼리
SELECT 
    'anon 역할 권한' as role_check,
    has_schema_privilege('anon', 'public', 'USAGE') as has_schema_usage,
    has_table_privilege('anon', 'public.moods', 'SELECT') as can_read_moods,
    has_table_privilege('anon', 'public.themes', 'SELECT') as can_read_themes,
    has_table_privilege('anon', 'public.tracks', 'SELECT') as can_read_tracks;

-- ============================= 완료 메시지 =============================
COMMENT ON SCHEMA public IS 'EverySleep 스키마 - anon/authenticated 역할에 접근 권한 부여됨';