-- 에브리슬립 정규화된 데이터 (데이터베이스 설계 원칙 적용)
-- Excel 데이터를 분석하여 정규화 및 가공

-- ================================
-- 1. 기분(MOODS) 데이터 정규화
-- ================================
INSERT INTO moods (name, emoji, color, display_order) VALUES ('귀에서 소리가 나요', '👂', '#E74C3C', 1);
INSERT INTO moods (name, emoji, color, display_order) VALUES ('기분 전환하고 싶어요', '🌈', '#F39C12', 2);
INSERT INTO moods (name, emoji, color, display_order) VALUES ('기운이 없어요', '😞', '#95A5A6', 3);
INSERT INTO moods (name, emoji, color, display_order) VALUES ('낮잠이 필요해요', '💤', '#9B59B6', 4);
INSERT INTO moods (name, emoji, color, display_order) VALUES ('조용히 쉬고싶어요', '🧘', '#27AE60', 5);
INSERT INTO moods (name, emoji, color, display_order) VALUES ('지쳤어요', '😔', '#E67E22', 6);
INSERT INTO moods (name, emoji, color, display_order) VALUES ('푹 자고 싶어요', '😴', '#4A90E2', 7);

-- ================================
-- 2. 키워드(KEYWORDS) 데이터 정규화
-- ================================
INSERT INTO keywords (name, category) VALUES ('긍정', '감정');
INSERT INTO keywords (name, category) VALUES ('기분전환', '효과');
INSERT INTO keywords (name, category) VALUES ('수면', '효과');
INSERT INTO keywords (name, category) VALUES ('안정', '효과');
INSERT INTO keywords (name, category) VALUES ('이명완화', '치료');
INSERT INTO keywords (name, category) VALUES ('이명케어', '치료');
INSERT INTO keywords (name, category) VALUES ('이완', '효과');
INSERT INTO keywords (name, category) VALUES ('집중', '효과');
INSERT INTO keywords (name, category) VALUES ('활력', '효과');

-- ================================
-- 3. 테마(THEMES) 데이터 정규화
-- ================================
INSERT INTO themes (code, title, subtitle, description, display_order) VALUES ('theme_01', '숙면 테라피', '매일 편안한 밤을 위한 맞춤형 음원을 만나보세요.', '안정적인 심박수에 최적화된 BPM과 규칙적인 리듬으로 설계하여 뇌파를 안정시키고, 깊은 이완을 유도하여 수면에 도움을 줍니다.', 1);
INSERT INTO themes (code, title, subtitle, description, display_order) VALUES ('theme_02', '마음 테라피', '편안한 심신과 평온을 되찾아 드립니다.', '불안하고 긴장된 마음을 위한 맞춤형 사운드입니다. 고요하고 조화로운 소리가 심리적 안정감을 경험하도록 돕습니다.', 2);
INSERT INTO themes (code, title, subtitle, description, display_order) VALUES ('theme_03', '이명 케어(자연소리)', '이명 소리를 케어해주는 편안한 자연의 소리를 만나보세요.', '이명을 효과적으로 마스킹할 수 있도록 설계한 백색소음 입니다. 평온하고 안정적인 상태를 돕습니다.', 3);
INSERT INTO themes (code, title, subtitle, description, display_order) VALUES ('theme_04', '활력 부스터', '지친 하루에 새로운 활력을 채워보세요.', '활기찬 에너지를 채우는 100BPM이상의 리듬을 고려하여 더욱 경쾌하고 긍정적인 분위기를 만들어줍니다. ', 4);
INSERT INTO themes (code, title, subtitle, description, display_order) VALUES ('theme_05', '자연의 음악', '아름다운 음악에 자연의 소리를 더해 풍요로운 일상을 선사합니다.', '시원한 파도, 편안한 빗소리, 자연의 소리와 음악을 함께 설계하였습니다. 즉각적인 안정 효과를 느껴보세요.', 5);
INSERT INTO themes (code, title, subtitle, description, display_order) VALUES ('theme_06', '일상의 낭만', '커피 한 잔, 즐거운 식사, 산책 등 특별한 감성을 더해드립니다.', '감각적인 재즈, 낭만적인 클래식을 더하여 공간에 맞는 음악을 더해보세요.', 6);

-- ================================
-- 4. 트랙(TRACKS) 데이터 정규화
-- ================================
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S001', '가장 행복한 꿈', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/happiest_dream.mp3', NULL, '수면음악', 260, 70, 'happiest_dream.mp3', '포근한 이불 속에서, 편안한 피아노 선율이 가장 행복했던 순간을 떠올리게 합니다. ', false, 1);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S002', '감사의 일기', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/thanks_diary.mp3', NULL, '자연음', 150, 65, 'thanks_diary.mp3', '별일 없던 하루가 문득 고맙게 느껴지는 저녁, 멜로디 하나하나가 당신의 마음에 스며들기를', false, 2);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S003', '다정한 휴식', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/gentle_jazz.mp3', NULL, '명상음악', 183, 80, 'gentle_jazz.mp3', '음악은 말없이 곁을 지켜주는 친구, 경쾌한 재즈 어떠세요?', false, 3);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S004', '들꽃처럼 피어나는 희망', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/hope_flower.mp3', NULL, '자연음', 230, 115, 'hope_flower.mp3', '길가 풀 밭 사이에 조용히 고개 든 들꽃 한 송이가 희망이라는 이름으로 피어납니다.', false, 4);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S005', '따스한 봄날의 노래', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/warm_spring_song.mp3', NULL, '자연음', 312, 65, 'warm_spring_song.mp3', '창문을 열어 맞는 봄바람같은 피아노 선율과 함께 하루의 시작을 천천히 시작해보는건 어떠세요?', false, 5);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S006', '마음을 다독이며', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/soothing_heart.mp3', NULL, '자연음', 323, 60, 'soothing_heart.mp3', '지금 이 순간, 부드러운 피아노 멜로디가 당신의 마음을 조용히 토닥여줄거예요. ', false, 6);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S007', '별빛이 남긴 추억', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/starlight_memory.mp3', NULL, '자연음', 190, 65, 'starlight_memory.mp3', '어두운 밤하늘을 바라보며, 마음 깊숙한 추억을 떠올려보세요.', false, 7);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S008', '비오는 경복궁 돌담길', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/rainy_gyeongbokgung.mp3', NULL, '자연음', 224, 70, 'rainy_gyeongbokgung.mp3', '부드러운 빗방울이 경복궁 돌담에 닿는 풍경을 담은 연주를 감상해보세요.', false, 8);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S009', '여름의 마음', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/like_summer.mp3', NULL, '자연음', 502, 62, 'like_summer.mp3', '풀내음이 밀려오는 한여름의 멜로디가 마음을 상쾌하게 꺼내줍니다. ', false, 9);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S010', '여름의 마음', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/liket_summer_asmr.mp3', NULL, '자연음', 450, 62, 'liket_summer_asmr.mp3', '천천히 내리는 풀잎 위의 빗방울, 여름비를 연상케하는 연주를 함께 들어보세요.', false, 10);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S011', '빗소리에 눈을 뜬 아침', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/morning_awake_asmr.mp3', NULL, '자연음', 311, 70, 'morning_awake_asmr.mp3', '창문을 두드리는 빗소리에 눈을 뜬 아침, 부드러운 선율이 하루의 시작을 조용히 다독여줍니다.', false, 11);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S012', '빗소리와 책장을 넘기며', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/book_pages_asmr.mp3', NULL, '자연음', 192, 76, 'book_pages_asmr.mp3', '책장을 넘길 때 마다 창밖 빗소리가 함께 흘러들고, 은은한 리듬이 마음에 젖어드는 하루', false, 12);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S013', '선선한 봄날의 기억', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/cool_spring_memory.mp3', NULL, '자연음', 474, 62, 'cool_spring_memory.mp3', '선선한 바람에 마음까지 편안해지는 봄날의 연주', false, 13);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S014', '아름다운 쉼표', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/beautiful_comma.mp3', NULL, '자연음', 259, 62, 'beautiful_comma.mp3', '고단했던 하루, 오늘은 이 음악에 기대어 위로받길', false, 14);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S015', '쉼이있는 순간', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/moment_rest.mp3', NULL, '자연음', 244, 68, 'moment_rest.mp3', '바쁜 일상 속 잠시라도 가만히 음악에 귀 기울이는 순간을 느껴보세요.', false, 15);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S016', '어른들의 자장가', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/adults_lullaby.mp3', NULL, '수면음악', 300, 65, 'adults_lullaby.mp3', '따뜻한 피아노 멜로디가 어릴 적 듣던 자장가처럼 마음을 위로해줍니다.', false, 16);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S017', '오늘도 수고했어요', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/you_did_well_today.mp3', NULL, '자연음', 546, 60, 'you_did_well_today.mp3', '오늘 하루도 수고 많았어요. 잔잔한 피아노 선율이 당신을 토닥여줄거예요.', false, 17);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S018', '좋은 꿈을 꿀거예요', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/have_good_dream.mp3', NULL, '수면음악', 256, 73, 'have_good_dream.mp3', '불 끄고 누워 조용히 눈을 감고 함께하는 연주, 포근한 멜로디가 당신을 좋은 꿈으로 이끌어줍니다.', false, 18);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S019', '평화로운 나의 아침', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/peaceful_morning.mp3', NULL, '명상음악', 193, 60, 'peaceful_morning.mp3', '햇살이 커튼 사이로 스며드는 지금, 평화로운 아침의 공기를 닮은 곡이 하루를 부드럽게 열어줍니다.', false, 19);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S020', '푸르른 공원 산책', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/park_walk.mp3', NULL, '자연음', 275, 65, 'park_walk.mp3', '푸르른 잔디밭을 거닐며, 일상에 생기를 더해주는 음악을 함께하세요.', false, 20);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S021', '푸르른 공원 산책', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/park_walk_asmr.mp3', NULL, '자연음', 275, 65, 'park_walk_asmr.mp3', '새들이 지저귀는 소리에 마음이 닿는 산책길, 오늘 더 여유롭게 하루를 맞이해보세요.', false, 21);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S022', '햇살 가득한 하루', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/sunshine_day.mp3', NULL, '활력음악', 587, 62, 'sunshine_day.mp3', '창문을 열고 햇살이 방 안을 환하게 채우고 뒤이어 들리는 피아노가 하루의 시작을 다독여줍니다.', false, 22);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S023', '햇살 가득한 하루', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/sunshine_day_asmr.mp3', NULL, '활력음악', 589, 62, 'sunshine_day_asmr.mp3', '햇살 속을 걷는 듯한 연주와 어우러지는 새소리가 여유로운 하루를 만들어줍니다.', false, 23);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S024', '행복이 있는 식탁', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/happy_table.mp3', NULL, '자연음', 123, 120, 'happy_table.mp3', '온기 가득한 식탁, 반가운 얼굴들이 함께하는 행복한 순간을 맞이하세요', false, 24);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S025', '흰나비의 날갯짓', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/butterfly_wings.mp3', NULL, '자연음', 337, 65, 'butterfly_wings.mp3', '흰나비 한 마리가 조용히 날아와 창문 밖을 바라보며 미소짓는 하루를 연상케 합니다.', false, 25);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S026', '기분좋은 식사', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/happy_dinner.mp3', NULL, '자연음', 951, 65, 'happy_dinner.mp3', '식탁 위의 따뜻한 음식, 커피잔의 향기, 그리고 부드러운 재즈 어떠신가요?', false, 26);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S027', '매일 더 사랑', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/more_love.mp3', NULL, '자연음', 238, 65, 'more_love.mp3', '사실 사랑은 가까이에 있어요.', false, 27);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S028', '벚꽃이 휘날리던 날', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/day_blossom.mp3', NULL, '자연음', 114, 140, 'day_blossom.mp3', '봄바람이 휘날리던 그곳, 흩날리던 그날의 장면을 함께 해요.', false, 28);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S029', '어느 봄날의 기억', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/memory_spring.mp3', NULL, '자연음', 117, 110, 'memory_spring.mp3', 'nan', false, 29);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S030', '희망의 빛을 따라서', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/following_hope.mp3', NULL, '자연음', 144, 65, 'following_hope.mp3', '조용히 당신 곁에 머물며, 희망을 건네는 피아노 선율 ', false, 30);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S031', '재즈 레스토랑', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/jazz_night.mp3', NULL, '자연음', 198, 150, 'jazz_night.mp3', '세련된 재즈가 흐르는 근사한 저녁 시간', false, 31);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S032', '새소리(ASMR)', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/bird_asmr.mp3', NULL, '자연음', 0, NULL, 'bird_asmr.mp3', '이른 아침 새들의 인사소리로 하루를 시작해보세요.', false, 32);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S033', '장작불소리(ASMR)', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/fire_asmr.mp3', NULL, '자연음', 0, NULL, 'fire_asmr.mp3', '벽난로 옆 장작이 타는 소리는 마음이 안정됩니다.', false, 33);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S034', '빗소리(ASMR)', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/rain_asmr.mp3', NULL, '자연음', 0, NULL, 'rain_asmr.mp3', '빗방울 리듬이 마음을 온전하게 만들어줍니다.', false, 34);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S035', '파도소리(ASMR)', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/wave_asmr.mp3', NULL, '자연음', 0, NULL, 'wave_asmr.mp3', '시원한 바닷바람과 파도소리로 휴식을 취하세요.', false, 35);
INSERT INTO tracks (code, title, artist, url, thumbnail, category, duration_seconds, bpm, file_name, description, is_asmr, display_order) 
VALUES ('S036', '물소리(ASMR)', '에브리슬립', 'https://jxfeszksnsyelaqcfapv.supabase.co/storage/v1/object/public/audio-tracks/water_asmr.mp3', NULL, '자연음', 0, NULL, 'water_asmr.mp3', '맑고 투명한 계곡물이 흐르는 숲 속에 귀기울여보세요.', false, 36);

-- ================================
-- 5. 관계 데이터 정규화
-- ================================
-- 테마-기분 관계
INSERT INTO theme_moods (theme_id, mood_id)
SELECT t.id, m.id FROM themes t, moods m 
WHERE t.code = 'theme_01' AND m.name = '푹 자고 싶어요';
INSERT INTO theme_moods (theme_id, mood_id)
SELECT t.id, m.id FROM themes t, moods m 
WHERE t.code = 'theme_01' AND m.name = '낮잠이 필요해요';
INSERT INTO theme_moods (theme_id, mood_id)
SELECT t.id, m.id FROM themes t, moods m 
WHERE t.code = 'theme_02' AND m.name = '지쳤어요';
INSERT INTO theme_moods (theme_id, mood_id)
SELECT t.id, m.id FROM themes t, moods m 
WHERE t.code = 'theme_03' AND m.name = '귀에서 소리가 나요';
INSERT INTO theme_moods (theme_id, mood_id)
SELECT t.id, m.id FROM themes t, moods m 
WHERE t.code = 'theme_04' AND m.name = '기운이 없어요';
INSERT INTO theme_moods (theme_id, mood_id)
SELECT t.id, m.id FROM themes t, moods m 
WHERE t.code = 'theme_05' AND m.name = '조용히 쉬고싶어요';
INSERT INTO theme_moods (theme_id, mood_id)
SELECT t.id, m.id FROM themes t, moods m 
WHERE t.code = 'theme_06' AND m.name = '기분 전환하고 싶어요';

-- 테마-트랙 관계
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 1 FROM themes t, tracks tr 
WHERE t.code = 'theme_01' AND tr.code = 'S001';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 2 FROM themes t, tracks tr 
WHERE t.code = 'theme_01' AND tr.code = 'S007';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 3 FROM themes t, tracks tr 
WHERE t.code = 'theme_01' AND tr.code = 'S008';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 4 FROM themes t, tracks tr 
WHERE t.code = 'theme_01' AND tr.code = 'S010';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 5 FROM themes t, tracks tr 
WHERE t.code = 'theme_01' AND tr.code = 'S013';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 6 FROM themes t, tracks tr 
WHERE t.code = 'theme_01' AND tr.code = 'S014';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 7 FROM themes t, tracks tr 
WHERE t.code = 'theme_01' AND tr.code = 'S016';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 8 FROM themes t, tracks tr 
WHERE t.code = 'theme_01' AND tr.code = 'S030';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 1 FROM themes t, tracks tr 
WHERE t.code = 'theme_02' AND tr.code = 'S002';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 2 FROM themes t, tracks tr 
WHERE t.code = 'theme_02' AND tr.code = 'S004';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 3 FROM themes t, tracks tr 
WHERE t.code = 'theme_02' AND tr.code = 'S005';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 4 FROM themes t, tracks tr 
WHERE t.code = 'theme_02' AND tr.code = 'S006';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 5 FROM themes t, tracks tr 
WHERE t.code = 'theme_02' AND tr.code = 'S008';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 6 FROM themes t, tracks tr 
WHERE t.code = 'theme_02' AND tr.code = 'S013';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 7 FROM themes t, tracks tr 
WHERE t.code = 'theme_02' AND tr.code = 'S015';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 8 FROM themes t, tracks tr 
WHERE t.code = 'theme_02' AND tr.code = 'S017';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 9 FROM themes t, tracks tr 
WHERE t.code = 'theme_02' AND tr.code = 'S018';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 10 FROM themes t, tracks tr 
WHERE t.code = 'theme_02' AND tr.code = 'S019';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 11 FROM themes t, tracks tr 
WHERE t.code = 'theme_02' AND tr.code = 'S022';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 1 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'S031';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 2 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'S032';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 3 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'S033';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 4 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'S034';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 5 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'S035';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 6 FROM themes t, tracks tr 
WHERE t.code = 'theme_03' AND tr.code = 'S036';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 1 FROM themes t, tracks tr 
WHERE t.code = 'theme_04' AND tr.code = 'S003';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 2 FROM themes t, tracks tr 
WHERE t.code = 'theme_04' AND tr.code = 'S004';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 3 FROM themes t, tracks tr 
WHERE t.code = 'theme_04' AND tr.code = 'S020';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 4 FROM themes t, tracks tr 
WHERE t.code = 'theme_04' AND tr.code = 'S024';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 5 FROM themes t, tracks tr 
WHERE t.code = 'theme_04' AND tr.code = 'S025';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 6 FROM themes t, tracks tr 
WHERE t.code = 'theme_04' AND tr.code = 'S028';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 1 FROM themes t, tracks tr 
WHERE t.code = 'theme_05' AND tr.code = 'S008';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 2 FROM themes t, tracks tr 
WHERE t.code = 'theme_05' AND tr.code = 'S009';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 3 FROM themes t, tracks tr 
WHERE t.code = 'theme_05' AND tr.code = 'S011';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 4 FROM themes t, tracks tr 
WHERE t.code = 'theme_05' AND tr.code = 'S012';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 5 FROM themes t, tracks tr 
WHERE t.code = 'theme_05' AND tr.code = 'S021';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 6 FROM themes t, tracks tr 
WHERE t.code = 'theme_05' AND tr.code = 'S023';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 1 FROM themes t, tracks tr 
WHERE t.code = 'theme_06' AND tr.code = 'S003';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 2 FROM themes t, tracks tr 
WHERE t.code = 'theme_06' AND tr.code = 'S026';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 3 FROM themes t, tracks tr 
WHERE t.code = 'theme_06' AND tr.code = 'S027';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 4 FROM themes t, tracks tr 
WHERE t.code = 'theme_06' AND tr.code = 'S028';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 5 FROM themes t, tracks tr 
WHERE t.code = 'theme_06' AND tr.code = 'S029';
INSERT INTO theme_tracks (theme_id, track_id, display_order)
SELECT t.id, tr.id, 6 FROM themes t, tracks tr 
WHERE t.code = 'theme_06' AND tr.code = 'S031';

-- 트랙-키워드 관계
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S001' AND k.name = '수면';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S001' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S002' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S002' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S003' AND k.name = '활력';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S003' AND k.name = '기분전환';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S004' AND k.name = '활력';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S004' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S004' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S005' AND k.name = '집중';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S005' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S005' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S006' AND k.name = '집중';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S006' AND k.name = '수면';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S006' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S007' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S007' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S007' AND k.name = '수면';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S007' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S008' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S008' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S008' AND k.name = '활력';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S009' AND k.name = '집중';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S009' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S009' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S010' AND k.name = '이명완화';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S010' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S010' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S011' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S011' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S012' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S012' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S013' AND k.name = '수면';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S013' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S014' AND k.name = '수면';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S014' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S014' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S014' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S015' AND k.name = '집중';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S015' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S015' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S016' AND k.name = '수면';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S016' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S017' AND k.name = '집중';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S017' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S017' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S018' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S018' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S019' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S019' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S020' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S020' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S020' AND k.name = '기분전환';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S021' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S021' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S022' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S022' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S023' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S023' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S023' AND k.name = '기분전환';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S024' AND k.name = '활력';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S024' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S024' AND k.name = '기분전환';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S025' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S025' AND k.name = '활력';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S026' AND k.name = '활력';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S026' AND k.name = '기분전환';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S027' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S027' AND k.name = '기분전환';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S028' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S028' AND k.name = '활력';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S028' AND k.name = '기분전환';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S029' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S029' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S029' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S030' AND k.name = '이완';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S030' AND k.name = '안정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S030' AND k.name = '수면';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S031' AND k.name = '긍정';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S031' AND k.name = '기분전환';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S032' AND k.name = '이명케어';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S033' AND k.name = '이명케어';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S034' AND k.name = '이명케어';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S035' AND k.name = '이명케어';
INSERT INTO track_keywords (track_id, keyword_id)
SELECT tr.id, k.id FROM tracks tr, keywords k 
WHERE tr.code = 'S036' AND k.name = '이명케어';