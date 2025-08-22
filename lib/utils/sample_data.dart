import '../models/track.dart';

class SampleData {
  // 자연음 효과음 (E001-E006) - 플레이어에서 믹싱용으로만 사용
  static List<Track> getNatureSoundEffects() {
    return [
      Track(
        id: 1001,
        code: 'E001',
        title: '새소리(ASMR)',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/e001_bird_asmr1.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/e001_bird_asmr1.jpg', // 새소리(ASMR)
        category: '자연음',
        durationSeconds: null, // 반복 재생
        bpm: null,
        displayOrder: 1001,
        fileName: 'e001_bird_asmr1.mp3',
        description: '이른 아침 새들의 인사소리로 하루를 시작해보세요.',
        effectKeywords: ['이명케어'],
        isAsmr: true,
        createdAt: DateTime.now(),
      ),
      Track(
        id: 1002,
        code: 'E002',
        title: '장작불소리(ASMR)',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/e002_fire_asmr.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/e002_fire_asmr.jpg', // 장작불소리(ASMR)
        category: '자연음',
        durationSeconds: null, // 반복 재생
        bpm: null,
        displayOrder: 1002,
        fileName: 'e002_fire_asmr.mp3',
        description: '벽난로 옆 장작이 타는 소리는 마음이 안정됩니다.',
        effectKeywords: ['이명케어'],
        isAsmr: true,
        createdAt: DateTime.now(),
      ),
      Track(
        id: 1003,
        code: 'E003',
        title: '빗소리(ASMR)',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/e003_rain_asmr2.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/e003_rain_asmr2.jpg', // 빗소리(ASMR)
        category: '자연음',
        durationSeconds: null, // 반복 재생
        bpm: null,
        displayOrder: 1003,
        fileName: 'e003_rain_asmr2.mp3',
        description: '빗방울 리듬이 마음을 온전하게 만들어줍니다.',
        effectKeywords: ['이명케어'],
        isAsmr: true,
        createdAt: DateTime.now(),
      ),
      Track(
        id: 1004,
        code: 'E004',
        title: '물소리(ASMR)',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/e004_water_asmr.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/e005_wave_asmr.jpg', // 물소리(ASMR)
        category: '자연음',
        durationSeconds: null, // 반복 재생
        bpm: null,
        displayOrder: 1004,
        fileName: 'e004_water_asmr.mp3',
        description: '맑고 투명한 계곡물이 흐르는 숲 속에 귀기울여보세요.',
        effectKeywords: ['이명케어'],
        isAsmr: true,
        createdAt: DateTime.now(),
      ),
      Track(
        id: 1005,
        code: 'E005',
        title: '파도소리(ASMR)',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/e005_wave_asmr.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/e004_water_asmr.jpg', // 파도소리(ASMR)
        category: '자연음',
        durationSeconds: null, // 반복 재생
        bpm: null,
        displayOrder: 1005,
        fileName: 'e005_wave_asmr.mp3',
        description: '시원한 바닷바람과 파도소리로 휴식을 취하세요.',
        effectKeywords: ['이명케어'],
        isAsmr: true,
        createdAt: DateTime.now(),
      ),
      Track(
        id: 1006,
        code: 'E006',
        title: '바람소리(ASMR)',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/e006_wind_asmr.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/e006_wind_asmr.jpg', // 바람소리(ASMR)
        category: '자연음',
        durationSeconds: null, // 반복 재생
        bpm: null,
        displayOrder: 1006,
        fileName: 'e006_wind_asmr.mp3',
        description: '시원해지는 숲 속의 바람소리로 마음을 이완시켜보세요.',
        effectKeywords: ['이명케어'],
        isAsmr: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  // 모든 트랙 (음악 + 자연음)
  static List<Track> getAllTracks() {
    // 자연음 효과음 먼저 추가
    final natureSounds = getNatureSoundEffects();
    
    // 음악 트랙들
    final musicTracks = [
      // 수면음악
      Track(
        id: 1,
        code: 'S001',
        title: '가장 행복한 꿈',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s001_happiest_dream.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/s001_happiest_dream.jpg',
        category: '수면음악',
        durationSeconds: 260, // 04:20
        bpm: 70,
        displayOrder: 1,
        fileName: 's001_happiest_dream.mp3',
        description: '포근한 이불 속에서, 편안한 피아노 선율이 가장 행복했던 순간을 떠올리게 합니다.',
        effectKeywords: ['수면', '이완'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 16,
        code: 'S016',
        title: '어른들의 자장가',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s016_adults_lullaby.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=300&h=300&fit=crop', // 자고있는 사람 - 밤의 저조도 분위기
        category: '수면음악',
        durationSeconds: 300, // 05:00
        bpm: 65,
        displayOrder: 16,
        fileName: 's016_adults_lullaby.mp3',
        description: '따뜻한 피아노 멜로디가 어릴 적 듣던 자장가처럼 마음을 위로해줍니다.',
        effectKeywords: ['수면', '긍정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 18,
        code: 'S018',
        title: '좋은 꿈을 꿀거예요',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s018_have_good_dream.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/c2.jpg', // 좋은 꿈을 꿀거예요 커스텀 이미지
        category: '수면음악',
        durationSeconds: 256, // 04:16
        bpm: 73,
        displayOrder: 18,
        fileName: 's018_have_good_dream.mp3',
        description: '불 끄고 누워 조용히 눈을 감고 함께하는 연주, 포근한 멜로디가 당신을 좋은 꿈으로 이끌어줍니다.',
        effectKeywords: ['이완', '안정'],
        createdAt: DateTime.now(),
      ),

      // 명상음악
      Track(
        id: 3,
        code: 'S003',
        title: '다정한 휴식',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s003_gentle_jazz.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/re2.jpg', // 다정한 휴식 커스텀 이미지
        category: '명상음악',
        durationSeconds: 183, // 03:03
        bpm: 80,
        displayOrder: 3,
        fileName: 's003_gentle_jazz.mp3',
        description: '음악은 말없이 곁을 지켜주는 친구, 경쾌한 재즈 어떠세요?',
        effectKeywords: ['활력', '기분전환'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 19,
        code: 'S019',
        title: '평화로운 나의 아침',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s019_peaceful_morning.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/f3.jpg', // 평화로운 나의 아침 커스텀 이미지
        category: '명상음악',
        durationSeconds: 193, // 03:13
        bpm: 60,
        displayOrder: 19,
        fileName: 's019_peaceful_morning.mp3',
        description: '햇살이 커튼 사이로 스며드는 지금, 평화로운 아침의 공기를 닮은 곡이 하루를 부드럽게 열어줍니다.',
        effectKeywords: ['긍정', '안정'],
        createdAt: DateTime.now(),
      ),

      // 활력음악
      Track(
        id: 22,
        code: 'S022',
        title: '햇살 가득한 하루',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s022_sunshine_day.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/f4.jpg', // 햇살 가득한 하루 커스텀 이미지
        category: '활력음악',
        durationSeconds: 587, // 09:47
        bpm: 62,
        displayOrder: 22,
        fileName: 's022_sunshine_day.mp3',
        description: '창문을 열고 햇살이 방 안을 환하게 채우고 뒤이어 들리는 피아노가 하루의 시작을 다독여줍니다.',
        effectKeywords: ['이완', '긍정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 23,
        code: 'S023',
        title: '햇살 가득한 하루 (ASMR)',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s023_sunshine_day_asmr.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/f4.jpg', // 햇살 가득한 하루 (ASMR) 커스텀 이미지
        category: '활력음악',
        durationSeconds: 589, // 09:49
        bpm: 62,
        displayOrder: 23,
        fileName: 's023_sunshine_day_asmr.mp3',
        description: '햇살 속을 걷는 듯한 연주와 어우러지는 새소리가 여유로운 하루를 만들어줍니다.',
        effectKeywords: ['이완', '긍정', '기분전환'],
        createdAt: DateTime.now(),
      ),

      // 자연음 - 고BPM (활력계열)
      Track(
        id: 4,
        code: 'S004',
        title: '들꽃처럼 피어나는 희망',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s004_hope_flower.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/f1.jpg', // 들꽃처럼 피어나는 희망 커스텀 이미지
        category: '수면음악',
        durationSeconds: 230, // 03:50
        bpm: 115,
        displayOrder: 4,
        fileName: 's004_hope_flower.mp3',
        description: '길가 풀 밭 사이에 조용히 고개 든 들꽃 한 송이가 희망이라는 이름으로 피어납니다.',
        effectKeywords: ['활력', '긍정', '안정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 24,
        code: 'S024',
        title: '행복이 있는 식탁',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s024_happy_table.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/shche_-team-0dszrg9-V1o-unsplash.jpg', // 행복이 있는 식탁 커스텀 이미지
        category: '활력음악',
        durationSeconds: 123, // 02:03
        bpm: 120,
        displayOrder: 24,
        fileName: 's024_happy_table.mp3',
        description: '온기 가득한 식탁, 반가운 얼굴들이 함께하는 행복한 순간을 맞이하세요',
        effectKeywords: ['활력', '긍정', '기분전환'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 28,
        code: 'S028',
        title: '벚꽃이 휘날리던 날',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s028_day_blossom.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=300&h=300&fit=crop', // 벚꽃이 휘날리는 봄 거리
        category: '활력음악',
        durationSeconds: 114, // 01:54
        bpm: 140,
        displayOrder: 28,
        fileName: 's028_day_blossom.mp3',
        description: '봄바람이 휘날리던 그곳, 흩날리던 그날의 장면을 함께 해요.',
        effectKeywords: ['긍정', '활력', '기분전환'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 29,
        code: 'S029',
        title: '행복의 봄',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s029_happy_spring.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=300&h=300&fit=crop', // 봄 새싹과 꽃들
        category: '수면음악',
        durationSeconds: 117, // 01:57
        bpm: 110,
        displayOrder: 29,
        fileName: 's029_happy_spring.mp3',
        description: '따뜻한 봄날의 기억을 떠올리며',
        effectKeywords: ['이완', '안정', '긍정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 31,
        code: 'S031',
        title: '재즈 레스토랑',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s031_jazz_restaurant.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=300&h=300&fit=crop', // 세련된 레스토랑 내부
        category: '활력음악',
        durationSeconds: 198, // 03:18
        bpm: 150,
        displayOrder: 31,
        fileName: 's031_jazz_restaurant.mp3',
        description: '세련된 재즈가 흐르는 근사한 저녁 시간',
        effectKeywords: ['긍정', '기분전환'],
        createdAt: DateTime.now(),
      ),

      // 자연음 - 안정/이완 계열
      Track(
        id: 2,
        code: 'S002',
        title: '감사의 일기',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s002_thanks_diary.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/thankyou.jpg', // 감사의 일기
        category: '수면음악',
        durationSeconds: 150, // 02:30
        bpm: 65,
        displayOrder: 2,
        fileName: 's002_thanks_diary.mp3',
        description: '별일 없던 하루가 문득 고맙게 느껴지는 저녁, 멜로디 하나하나가 당신의 마음에 스며들기를',
        effectKeywords: ['이완', '안정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 5,
        code: 'S005',
        title: '따스한 봄날의 노래',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s005_warm_spring_song.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?w=300&h=300&fit=crop', // 따스한 봄 거리 풍경
        category: '수면음악',
        durationSeconds: 312, // 05:12
        bpm: 65,
        displayOrder: 5,
        fileName: 's005_warm_spring_song.mp3',
        description: '창문을 열어 맞는 봄바람같은 피아노 선율과 함께 하루의 시작을 천천히 시작해보는건 어떠세요?',
        effectKeywords: ['집중', '이완', '긍정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 6,
        code: 'S006',
        title: '마음을 다독이며',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s006_soothing_heart.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/giulia-bertelli-dvXGnwnYweM-unsplash.jpg', // 마음을 다독이며 - 가슴에 손을 올린 따뜻한 이미지
        category: '수면음악',
        durationSeconds: 323, // 05:23
        bpm: 60,
        displayOrder: 6,
        fileName: 's006_soothing_heart.mp3',
        description: '지금 이 순간, 부드러운 피아노 멜로디가 당신의 마음을 조용히 토닥여줄거예요.',
        effectKeywords: ['집중', '수면', '이완'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 7,
        code: 'S007',
        title: '별빛이 남긴 추억',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s007_star_memory.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/marek-piwnicki-iwabZE-qN_U-unsplash.jpg', // 별빛이 남긴 추억 커스텀 이미지
        category: '수면음악',
        durationSeconds: 190, // 03:10
        bpm: 65,
        displayOrder: 7,
        fileName: 's007_star_memory.mp3',
        description: '어두운 밤하늘을 바라보며, 마음 깊숙한 추억을 떠올려보세요.',
        effectKeywords: ['긍정', '이완', '수면', '안정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 8,
        code: 'S008',
        title: '비오는 경복궁 돌담길',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s008_rainy_gyeongbokgung.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1545221167-d3fba6820656?w=300&h=300&fit=crop', // 경복궁 돌담
        category: '명상음악',
        durationSeconds: 224, // 03:44
        bpm: 70,
        displayOrder: 8,
        fileName: 's008_rainy_gyeongbokgung.mp3',
        description: '부드러운 빗방울이 경복궁 돌담에 닿는 풍경을 담은 연주를 감상해보세요.',
        effectKeywords: ['긍정', '이완', '활력'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 9,
        code: 'S009',
        title: '여름의 마음',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s009_heart_summer.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=300&h=300&fit=crop', // 여름 풍경
        category: '명상음악',
        durationSeconds: 502, // 08:22
        bpm: 62,
        displayOrder: 9,
        fileName: 's009_heart_summer.mp3',
        description: '풀내음이 밀려오는 한여름의 멜로디가 마음을 상쾌하게 꺼내줍니다.',
        effectKeywords: ['집중', '이완', '안정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 10,
        code: 'S010',
        title: '여름의 마음 (ASMR)',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s010_heart_summer_asmr.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=300&h=300&fit=crop', // 여름 풍경
        category: '명상음악',
        durationSeconds: 450, // 07:30
        bpm: 62,
        displayOrder: 10,
        fileName: 's010_heart_summer_asmr.mp3',
        description: '천천히 내리는 풀잎 위의 빗방울, 여름비를 연상케하는 연주를 함께 들어보세요.',
        effectKeywords: ['이명완화', '이완', '안정'],
        isAsmr: true,
        createdAt: DateTime.now(),
      ),
      Track(
        id: 11,
        code: 'S011',
        title: '빗소리에 눈을 뜬 아침',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s011_morning_awake_asmr.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1501436513145-30f24e19fcc4?w=300&h=300&fit=crop', // 아침 빗소리
        category: '명상음악',
        durationSeconds: 311, // 05:11
        bpm: 70,
        displayOrder: 11,
        fileName: 's011_morning_awake_asmr.mp3',
        description: '창문을 두드리는 빗소리에 눈을 뜬 아침, 부드러운 선율이 하루의 시작을 조용히 다독여줍니다.',
        effectKeywords: ['긍정', '안정'],
        isAsmr: true,
        createdAt: DateTime.now(),
      ),
      Track(
        id: 12,
        code: 'S012',
        title: '빗소리와 책장을 넘기며',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s012_book_pages_asmr.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=300&h=300&fit=crop', // 책과 빗소리
        category: '명상음악',
        durationSeconds: 192, // 03:12
        bpm: 76,
        displayOrder: 12,
        fileName: 's012_book_pages_asmr.mp3',
        description: '책장을 넘길 때 마다 창밖 빗소리가 함께 흘러들고, 은은한 리듬이 마음에 젖어드는 하루',
        effectKeywords: ['긍정', '안정'],
        isAsmr: true,
        createdAt: DateTime.now(),
      ),
      Track(
        id: 13,
        code: 'S013',
        title: '선선한 봄날의 기억',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s013_spring_memory.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=300&h=300&fit=crop', // 봄날 풍경
        category: '수면음악',
        durationSeconds: 474, // 07:54
        bpm: 62,
        displayOrder: 13,
        fileName: 's013_spring_memory.mp3',
        description: '선선한 바람에 마음까지 편안해지는 봄날의 연주',
        effectKeywords: ['수면', '안정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 14,
        code: 'S014',
        title: '아름다운 쉼표',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s014_beautiful_comma.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=300&fit=crop', // 휴식
        category: '수면음악',
        durationSeconds: 259, // 04:19
        bpm: 62,
        displayOrder: 14,
        fileName: 's014_beautiful_comma.mp3',
        description: '고단했던 하루, 오늘은 이 음악에 기대어 위로받길',
        effectKeywords: ['수면', '안정', '이완', '긍정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 15,
        code: 'S015',
        title: '쉼이있는 순간',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s015_moment_rest.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1516905365441-80295fccd862?w=300&h=300&fit=crop', // 쉼
        category: '명상음악',
        durationSeconds: 244, // 04:04
        bpm: 68,
        displayOrder: 15,
        fileName: 's015_moment_rest.mp3',
        description: '바쁜 일상 속 잠시라도 가만히 음악에 귀 기울이는 순간을 느껴보세요.',
        effectKeywords: ['집중', '이완', '안정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 17,
        code: 'S017',
        title: '오늘도 수고했어요',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s017_well_today.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=300&fit=crop', // 위로
        category: '수면음악',
        durationSeconds: 546, // 09:06
        bpm: 60,
        displayOrder: 17,
        fileName: 's017_well_today.mp3',
        description: '오늘 하루도 수고 많았어요. 잔잔한 피아노 선율이 당신을 토닥여줄거예요.',
        effectKeywords: ['집중', '이완', '안정'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 20,
        code: 'S020',
        title: '푸르른 공원 산책',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s020_park_walk.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=300&h=300&fit=crop', // 공원 산책
        category: '활력음악',
        durationSeconds: 275, // 04:35
        bpm: 65,
        displayOrder: 20,
        fileName: 's020_park_walk.mp3',
        description: '푸르른 잔디밭을 거닐며, 일상에 생기를 더해주는 음악을 함께하세요.',
        effectKeywords: ['긍정', '안정', '기분전환'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 21,
        code: 'S021',
        title: '푸르른 공원 산책 (ASMR)',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s021_park_walk_asmr.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=300&h=300&fit=crop', // 공원 산책
        category: '활력음악',
        durationSeconds: 275, // 04:35
        bpm: 65,
        displayOrder: 21,
        fileName: 's021_park_walk_asmr.mp3',
        description: '새들이 지저귀는 소리에 마음이 닿는 산책길, 오늘 더 여유롭게 하루를 맞이해보세요.',
        effectKeywords: ['긍정', '안정'],
        isAsmr: true,
        createdAt: DateTime.now(),
      ),
      Track(
        id: 25,
        code: 'S025',
        title: '흰나비의 날갯짓',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s025_butterfly_wings.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=300&h=300&fit=crop', // 나비
        category: '활력음악',
        durationSeconds: 337, // 05:37
        bpm: 65,
        displayOrder: 25,
        fileName: 's025_butterfly_wings.mp3',
        description: '흰나비 한 마리가 조용히 날아와 창문 밖을 바라보며 미소짓는 하루를 연상케 합니다.',
        effectKeywords: ['긍정', '활력'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 26,
        code: 'S026',
        title: '비 내리는 창가에 앉아',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s026_rainy_chill.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=300&h=300&fit=crop', // 창가 빗소리
        category: '활력음악',
        durationSeconds: 951, // 15:51
        bpm: 65,
        displayOrder: 26,
        fileName: 's026_rainy_chill.mp3',
        description: '식탁 위의 따뜻한 음식, 커피잔의 향기, 그리고 부드러운 재즈 어떠신가요?',
        effectKeywords: ['활력', '기분전환'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 27,
        code: 'S027',
        title: '매일 더 사랑',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s027_more_love.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=300&h=300&fit=crop', // 사랑
        category: '활력음악',
        durationSeconds: 238, // 03:58
        bpm: 65,
        displayOrder: 27,
        fileName: 's027_more_love.mp3',
        description: '사실 사랑은 가까이에 있어요.',
        effectKeywords: ['긍정', '기분전환'],
        createdAt: DateTime.now(),
      ),
      Track(
        id: 30,
        code: 'S030',
        title: '희망의 빛을 따라서',
        artist: 'everysleep',
        url: 'https://everysleep.b-cdn.net/tracks/s030_following_hope.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/wolf-zimmermann-6sf5rf8QYFE-unsplash.jpg',
        category: '수면음악',
        durationSeconds: 144, // 02:24
        bpm: 65,
        displayOrder: 30,
        fileName: 's030_following_hope.mp3',
        description: '조용히 당신 곁에 머물며, 희망을 건네는 피아노 선율',
        effectKeywords: ['이완', '안정', '수면'],
        createdAt: DateTime.now(),
      ),
    ];
    
    // 자연음과 음악 트랙을 합쳐서 반환
    return [...natureSounds, ...musicTracks];
  }

  static List<Track> getRecommendedTracks() {
    final allTracks = getAllTracks();
    allTracks.shuffle();
    return allTracks.take(3).toList();
  }

  static List<Track> getTracksByCategory(String category) {
    if (category == '전체') {
      return getAllTracks();
    }
    return getAllTracks()
        .where((track) => track.category == category)
        .toList();
  }

  static List<Track> getTracksByEmotion(String emotion) {
    switch (emotion) {
      case 'energy':
        return getAllTracks()
            .where((track) => track.effectKeywords.any((keyword) => 
                keyword.contains('활력') || keyword.contains('기분전환')))
            .toList();
      case 'stress':
        return getAllTracks()
            .where((track) => track.effectKeywords.any((keyword) => 
                keyword.contains('이완') || keyword.contains('안정')))
            .toList();
      case 'anxiety':
        return getAllTracks()
            .where((track) => track.effectKeywords.any((keyword) => 
                keyword.contains('안정') || keyword.contains('긍정')))
            .toList();
      case 'sleep':
        return getAllTracks()
            .where((track) => track.effectKeywords.any((keyword) => 
                keyword.contains('수면') || keyword.contains('이완')))
            .toList();
      case 'focus':
        return getAllTracks()
            .where((track) => track.effectKeywords.contains('집중'))
            .toList();
      case 'tinnitus':
        return getAllTracks()
            .where((track) => track.effectKeywords.contains('이명케어'))
            .toList();
      default:
        return getRecommendedTracks();
    }
  }

  static List<String> getCategories() {
    return ['전체', '수면음악', '명상음악', '활력음악'];
  }

  static List<String> getNatureSounds() {
    return [
      '빗소리',
      '파도소리',
      '새소리',
      '바람소리',
      '시냇물소리',
    ];
  }

  static List<String> getEffectKeywords() {
    return [
      '수면',
      '이완',
      '안정',
      '활력',
      '긍정',
      '기분전환',
      '집중',
      '이명케어',
    ];
  }

  // BPM 범위별 트랙 조회
  static List<Track> getTracksByBPMRange(int minBPM, int maxBPM) {
    return getAllTracks()
        .where((track) => track.bpm != null && 
               track.bpm! >= minBPM && 
               track.bpm! <= maxBPM)
        .toList();
  }

  // 수면용 트랙 (60-70 BPM)
  static List<Track> getSleepTracks() {
    return getTracksByBPMRange(60, 70)
        .where((track) => track.effectKeywords.contains('수면') || 
                         track.effectKeywords.contains('이완'))
        .toList();
  }

  // 활력용 트랙 (80+ BPM)
  static List<Track> getEnergyTracks() {
    return getAllTracks()
        .where((track) => track.bpm != null && track.bpm! >= 80)
        .toList();
  }

  // 명상용 트랙 (60-80 BPM)
  static List<Track> getMeditationTracks() {
    return getTracksByBPMRange(60, 80)
        .where((track) => track.effectKeywords.contains('안정') || 
                         track.effectKeywords.contains('집중'))
        .toList();
  }
}