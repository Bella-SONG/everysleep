-- user_feedback 테이블에 selected_options 컬럼 추가
-- 세부적인 피드백 옵션을 저장하기 위함

-- selected_options 컬럼 추가 (JSONB 타입)
ALTER TABLE user_feedback 
ADD COLUMN selected_options JSONB DEFAULT '[]'::jsonb;

-- 인덱스 추가 (피드백 옵션 분석을 위해)
CREATE INDEX idx_user_feedback_selected_options ON user_feedback USING GIN (selected_options);

-- 상태 확인
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'user_feedback' 
    AND table_schema = 'public'
ORDER BY ordinal_position;