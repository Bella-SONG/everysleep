-- 기본 tracks 테이블 생성
CREATE TABLE IF NOT EXISTS tracks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  artist TEXT NOT NULL,
  url TEXT NOT NULL,
  thumbnail TEXT,
  category TEXT,
  duration_seconds INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- tracks 테이블 RLS 활성화
ALTER TABLE tracks ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 tracks를 읽을 수 있음
CREATE POLICY "Tracks are viewable by all users" ON tracks
  FOR SELECT USING (true);

-- 기본 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_tracks_created_at ON tracks(created_at);