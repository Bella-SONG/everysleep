-- 사용자 프로필 테이블 생성 및 RLS 문제 해결

-- ============================= USER PROFILES TABLE 생성 =============================
CREATE TABLE user_profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname TEXT NOT NULL,
  birth_year INTEGER,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  
  -- 카카오 로그인 관련 필드
  kakao_id TEXT UNIQUE,
  
  -- 메타데이터
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- 제약조건
  CONSTRAINT valid_birth_year CHECK (birth_year IS NULL OR (birth_year >= 1900 AND birth_year <= EXTRACT(YEAR FROM NOW())))
);

-- user_profiles 테이블 인덱스
CREATE INDEX idx_user_profiles_kakao_id ON user_profiles(kakao_id);
CREATE INDEX idx_user_profiles_nickname ON user_profiles(nickname);

-- updated_at 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $func$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$func$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================= RLS 정책 설정 =============================

-- user_profiles 테이블 RLS 활성화 및 정책 설정
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "사용자 본인 프로필 조회" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "사용자 본인 프로필 생성" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "사용자 본인 프로필 수정" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "사용자 본인 프로필 삭제" ON user_profiles
  FOR DELETE USING (auth.uid() = user_id);

-- ============================= 공개 데이터 테이블 RLS 문제 해결 =============================
-- 기존 정책들 삭제 후 새로 생성

DROP POLICY IF EXISTS "모든 사용자 테마 읽기 허용" ON themes;
DROP POLICY IF EXISTS "모든 사용자 트랙 읽기 허용" ON tracks;
DROP POLICY IF EXISTS "모든 사용자 기분 읽기 허용" ON moods;
DROP POLICY IF EXISTS "모든 사용자 키워드 읽기 허용" ON keywords;
DROP POLICY IF EXISTS "모든 사용자 테마-기분 관계 읽기 허용" ON theme_moods;
DROP POLICY IF EXISTS "모든 사용자 테마-트랙 관계 읽기 허용" ON theme_tracks;
DROP POLICY IF EXISTS "모든 사용자 트랙-키워드 관계 읽기 허용" ON track_keywords;

-- 더 명확한 정책으로 다시 생성 (anonymous 사용자도 접근 가능)
CREATE POLICY "공개 테마 데이터 읽기" ON themes
  FOR SELECT USING (true);

CREATE POLICY "공개 트랙 데이터 읽기" ON tracks
  FOR SELECT USING (true);

CREATE POLICY "공개 기분 데이터 읽기" ON moods
  FOR SELECT USING (true);

CREATE POLICY "공개 키워드 데이터 읽기" ON keywords
  FOR SELECT USING (true);

CREATE POLICY "공개 테마-기분 관계 읽기" ON theme_moods
  FOR SELECT USING (true);

CREATE POLICY "공개 테마-트랙 관계 읽기" ON theme_tracks
  FOR SELECT USING (true);

CREATE POLICY "공개 트랙-키워드 관계 읽기" ON track_keywords
  FOR SELECT USING (true);

-- ============================= 카카오 로그인을 위한 함수 생성 =============================

-- 카카오 로그인 후 프로필 생성/업데이트 함수
CREATE OR REPLACE FUNCTION handle_kakao_user(
  p_user_id UUID,
  p_kakao_id TEXT,
  p_nickname TEXT
)
RETURNS user_profiles AS $func$
DECLARE
  profile user_profiles;
BEGIN
  -- 기존 프로필이 있는지 확인
  SELECT * INTO profile FROM user_profiles WHERE user_id = p_user_id;
  
  IF profile IS NULL THEN
    -- 새 프로필 생성 (카카오에서 받은 닉네임으로 초기 설정)
    INSERT INTO user_profiles (
      user_id, 
      kakao_id, 
      nickname
    ) VALUES (
      p_user_id, 
      p_kakao_id, 
      p_nickname
    ) RETURNING * INTO profile;
  ELSE
    -- 기존 프로필의 로그인 시간만 업데이트 (닉네임은 사용자가 직접 변경할 수 있도록)
    UPDATE user_profiles SET
      updated_at = NOW()
    WHERE user_id = p_user_id
    RETURNING * INTO profile;
  END IF;
  
  RETURN profile;
END;
$func$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================= 완료 메시지 =============================
COMMENT ON TABLE user_profiles IS '카카오 로그인 사용자 프로필 테이블 - 닉네임(필수), 생년월일, 성별(선택)';
COMMENT ON FUNCTION handle_kakao_user IS '카카오 로그인 후 사용자 프로필 생성/업데이트 함수';