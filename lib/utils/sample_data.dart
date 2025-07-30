import '../models/track.dart';

class SampleData {
  static List<Track> getAllTracks() {
    return [
      Track(
        id: '1',
        title: '편안한 밤의 멜로디',
        artist: 'Sleep Harmony',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=300&fit=crop',
        category: '수면',
        duration: const Duration(minutes: 5, seconds: 30),
      ),
      Track(
        id: '2',
        title: '아침의 활력',
        artist: 'Morning Energy',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1464822759844-d150baec0494?w=300&h=300&fit=crop',
        category: '아침',
        duration: const Duration(minutes: 4, seconds: 15),
      ),
      Track(
        id: '3',
        title: '스트레스 완화 명상',
        artist: 'Calm Mind',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=300&fit=crop',
        category: '명상',
        duration: const Duration(minutes: 10, seconds: 0),
      ),
      Track(
        id: '4',
        title: '불안감 해소 음악',
        artist: 'Peace Journey',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=300&h=300&fit=crop',
        category: '불안감소',
        duration: const Duration(minutes: 7, seconds: 45),
      ),
      Track(
        id: '5',
        title: '저녁의 휴식',
        artist: 'Evening Rest',
        url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        thumbnail: 'https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=300&h=300&fit=crop',
        category: '저녁',
        duration: const Duration(minutes: 6, seconds: 20),
      ),
    ];
  }

  static List<Track> getRecommendedTracks() {
    final allTracks = getAllTracks();
    allTracks.shuffle();
    return allTracks.take(3).toList();
  }

  static List<Track> getTracksByCategory(String category) {
    return getAllTracks()
        .where((track) => track.category == category)
        .toList();
  }

  static List<Track> getTracksByEmotion(String emotion) {
    switch (emotion) {
      case 'energy':
        return getAllTracks()
            .where((track) => track.category == '아침' || track.category == '활력증진')
            .toList();
      case 'stress':
        return getAllTracks()
            .where((track) => track.category == '명상' || track.category == '스트레스해소')
            .toList();
      case 'anxiety':
        return getAllTracks()
            .where((track) => track.category == '불안감소' || track.category == '명상')
            .toList();
      case 'sleep':
        return getAllTracks()
            .where((track) => track.category == '수면' || track.category == '저녁')
            .toList();
      default:
        return getRecommendedTracks();
    }
  }

  static List<String> getCategories() {
    return ['추천', '아침', '저녁', '수면', '명상', '불안감소', '활력증진'];
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
}