-- RLS 상태 확인 쿼리들

-- 1. 모든 테이블의 RLS 상태 확인
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled,
  hasrls as has_rls_policies
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;

-- 2. 현재 적용된 RLS 정책들 확인
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 3. 특정 테이블들의 RLS 상태 확인
SELECT 
  table_name,
  table_schema,
  is_insertable_into,
  is_typed
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('themes', 'tracks', 'moods', 'keywords')
ORDER BY table_name;