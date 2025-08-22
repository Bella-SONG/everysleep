import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../models/nature_sound.dart';
import '../utils/sample_data.dart';
import 'track_repository.dart';

/// SampleData를 사용한 TrackRepository 구현체 (개발/테스트용)
class SampleTrackRepository implements TrackRepository {
  
  @override
  Future<List<Track>> getAllTracks() async {
    try {
      // 비동기 시뮬레이션을 위한 약간의 지연
      await Future.delayed(const Duration(milliseconds: 100));
      return SampleData.getAllTracks();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getAllTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getTracksByCategory(String category) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return SampleData.getTracksByCategory(category);
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getTracksByCategory error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getRecommendedTracks() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return SampleData.getRecommendedTracks();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getRecommendedTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getTracksByEmotion(String emotion) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return SampleData.getTracksByEmotion(emotion);
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getTracksByEmotion error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getNatureSoundEffects() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return SampleData.getNatureSoundEffects();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getNatureSoundEffects error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getAsmrTracks() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      final allTracks = SampleData.getAllTracks();
      return allTracks.where((track) => track.isAsmr == true).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getAsmrTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getTracksByBPMRange(int minBPM, int maxBPM) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return SampleData.getTracksByBPMRange(minBPM, maxBPM);
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getTracksByBPMRange error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getSleepTracks() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return SampleData.getSleepTracks();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getSleepTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getEnergyTracks() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return SampleData.getEnergyTracks();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getEnergyTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getMeditationTracks() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return SampleData.getMeditationTracks();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getMeditationTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<String>> getCategories() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return SampleData.getCategories();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getCategories error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<String>> getEffectKeywordCategories() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return [
        '전체',
        '수면',
        '이완',
        '안정',
        '활력',
        '긍정',
        '기분전환',
        '집중',
        '이명케어',
      ];
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getEffectKeywordCategories error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getTracksByEffectKeyword(String keyword) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      final allTracks = SampleData.getAllTracks();
      
      if (keyword == '전체') {
        // displayOrder로 정렬하여 반환
        final sortedTracks = List<Track>.from(allTracks);
        sortedTracks.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        return sortedTracks;
      }
      
      // 해당 키워드를 포함하는 트랙들 필터링
      return allTracks.where((track) => 
        track.effectKeywords.contains(keyword)
      ).toList()..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getTracksByEffectKeyword error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<String>> getNatureSounds() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return SampleData.getNatureSounds();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getNatureSounds error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<String>> getEffectKeywords() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return SampleData.getEffectKeywords();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getEffectKeywords error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<Track?> getTrackById(int trackId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      final allTracks = SampleData.getAllTracks();
      return allTracks.where((track) => track.id == trackId).firstOrNull;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getTrackById error: $e');
      }
      rethrow;
    }
  }
  
  // === 자연음 전용 메서드 구현 (샘플 데이터) ===
  
  @override
  Future<List<NatureSound>> getAllNatureSounds() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return _getSampleNatureSounds();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getAllNatureSounds error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<NatureSound>> getActiveNatureSounds() async {
    try {
      final allSounds = await getAllNatureSounds();
      return allSounds.where((sound) => sound.isActive).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getActiveNatureSounds error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<NatureSound?> getNatureSoundByCode(String code) async {
    try {
      final allSounds = await getAllNatureSounds();
      return allSounds.where((sound) => sound.code == code).firstOrNull;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getNatureSoundByCode error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<NatureSound>> getNatureSoundsSorted() async {
    try {
      final activeSounds = await getActiveNatureSounds();
      activeSounds.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return activeSounds;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SampleTrackRepository.getNatureSoundsSorted error: $e');
      }
      rethrow;
    }
  }
  
  /// 샘플 자연음 데이터 생성
  List<NatureSound> _getSampleNatureSounds() {
    return [
      NatureSound(
        id: 1,
        code: 'E001',
        title: '새소리(ASMR)',
        description: '이른 아침 새들의 인사소리로 하루를 시작해보세요.',
        url: 'https://everysleep.b-cdn.net/effects/E001_BIRD_ASMR1.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/E001_BIRD_ASMR1.jpg',
        fileName: 'E001_BIRD_ASMR1.mp3',
        iconName: 'raven',
        colorCode: '#FFC107',
        displayOrder: 1,
      ),
      NatureSound(
        id: 2,
        code: 'E002',
        title: '장작불소리(ASMR)',
        description: '벽난로 옆 장작이 타는 소리는 마음이 안정됩니다.',
        url: 'https://everysleep.b-cdn.net/effects/E002_FIRE_ASMR.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/E002_FIRE_ASMR.jpg',
        fileName: 'E002_FIRE_ASMR.mp3',
        iconName: 'fire',
        colorCode: '#FF5722',
        displayOrder: 2,
      ),
      NatureSound(
        id: 3,
        code: 'E003',
        title: '빗소리(ASMR)',
        description: '빗방울 리듬이 마음을 온전하게 만들어줍니다.',
        url: 'https://everysleep.b-cdn.net/effects/E003_RAIN_ASMR2.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/E003_RAIN_ASMR2.jpg',
        fileName: 'E003_RAIN_ASMR2.mp3',
        iconName: 'rain',
        colorCode: '#4CAF50',
        displayOrder: 3,
      ),
      NatureSound(
        id: 4,
        code: 'E004',
        title: '물소리(ASMR)',
        description: '맑고 투명한 계곡물이 흐르는 숲 속에 귀기울여보세요.',
        url: 'https://everysleep.b-cdn.net/effects/E004_WATER_ASMR.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/E004_WATER_ASMR.jpg',
        fileName: 'E004_WATER_ASMR.mp3',
        iconName: 'water_drop',
        colorCode: '#03A9F4',
        displayOrder: 4,
      ),
      NatureSound(
        id: 5,
        code: 'E005',
        title: '파도소리(ASMR)',
        description: '시원한 바닷바람과 파도소리로 휴식을 취하세요.',
        url: 'https://everysleep.b-cdn.net/effects/E005_WAVE_ASMR.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/E005_WAVE_ASMR.jpg',
        fileName: 'E005_WAVE_ASMR.mp3',
        iconName: 'waves',
        colorCode: '#2196F3',
        displayOrder: 5,
      ),
      NatureSound(
        id: 6,
        code: 'E006',
        title: '바람소리(ASMR)',
        description: '시원해지는 숲 속의 바람소리로 마음을 이완시켜보세요.',
        url: 'https://everysleep.b-cdn.net/effects/E006_WIND_ASMR.mp3',
        thumbnail: 'https://everysleep.b-cdn.net/thumbnails/E006_WIND_ASMR.jpg',
        fileName: 'E006_WIND_ASMR.mp3',
        iconName: 'air',
        colorCode: '#607D8B',
        displayOrder: 6,
      ),
    ];
  }
}