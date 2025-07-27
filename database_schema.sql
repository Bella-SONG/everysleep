-- EverySleep Database Schema for Supabase

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Create tracks table
CREATE TABLE IF NOT EXISTS tracks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist VARCHAR(100) NOT NULL,
    url TEXT NOT NULL,
    thumbnail TEXT,
    category VARCHAR(50) NOT NULL,
    duration_seconds INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_listening_history table
CREATE TABLE IF NOT EXISTS user_listening_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    track_id UUID REFERENCES tracks NOT NULL,
    listened_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    duration_listened INTEGER DEFAULT 0, -- in seconds
    completed BOOLEAN DEFAULT FALSE
);

-- Create user_preferences table
CREATE TABLE IF NOT EXISTS user_preferences (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    preferred_categories TEXT[], -- array of category names
    music_volume DECIMAL(3,2) DEFAULT 0.7,
    nature_volume DECIMAL(3,2) DEFAULT 0.3,
    default_sleep_timer INTEGER DEFAULT 30, -- in minutes
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Insert default categories
INSERT INTO categories (name, description, icon) VALUES
('추천', '개인화된 추천 음악', 'recommend'),
('아침', '상쾌한 아침을 위한 음악', 'morning'),
('저녁', '편안한 저녁을 위한 음악', 'evening'),
('수면', '깊은 잠을 위한 음악', 'sleep'),
('명상', '마음의 평화를 위한 음악', 'meditation'),
('불안감소', '불안감 해소를 위한 음악', 'calm'),
('활력증진', '에너지 충전을 위한 음악', 'energy')
ON CONFLICT (name) DO NOTHING;

-- Insert sample tracks
INSERT INTO tracks (title, artist, url, thumbnail, category, duration_seconds) VALUES
('편안한 밤의 멜로디', 'Sleep Harmony', 'https://example.com/track1.mp3', 'https://via.placeholder.com/150', '수면', 330),
('아침의 활력', 'Morning Energy', 'https://example.com/track2.mp3', 'https://via.placeholder.com/150', '아침', 255),
('스트레스 완화 명상', 'Calm Mind', 'https://example.com/track3.mp3', 'https://via.placeholder.com/150', '명상', 600),
('불안감 해소 음악', 'Peace Journey', 'https://example.com/track4.mp3', 'https://via.placeholder.com/150', '불안감소', 465),
('저녁의 휴식', 'Evening Rest', 'https://example.com/track5.mp3', 'https://via.placeholder.com/150', '저녁', 380),
('깊은 수면을 위한 소리', 'Deep Sleep', 'https://example.com/track6.mp3', 'https://via.placeholder.com/150', '수면', 720),
('갱년기 완화 음악', 'Menopause Relief', 'https://example.com/track7.mp3', 'https://via.placeholder.com/150', '명상', 540),
('시니어 웰니스', 'Senior Wellness', 'https://example.com/track8.mp3', 'https://via.placeholder.com/150', '추천', 420)
ON CONFLICT DO NOTHING;

-- Create RLS (Row Level Security) policies
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_listening_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- User profiles policies
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = user_id);

-- User listening history policies
CREATE POLICY "Users can view own listening history" ON user_listening_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own listening history" ON user_listening_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User preferences policies
CREATE POLICY "Users can view own preferences" ON user_preferences
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own preferences" ON user_preferences
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences" ON user_preferences
    FOR UPDATE USING (auth.uid() = user_id);

-- Tracks and categories are public (readable by all authenticated users)
CREATE POLICY "Authenticated users can view tracks" ON tracks
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view categories" ON categories
    FOR SELECT USING (auth.role() = 'authenticated');

-- Create functions and triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tracks_updated_at 
    BEFORE UPDATE ON tracks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at 
    BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();