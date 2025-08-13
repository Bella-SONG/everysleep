import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../models/nature_sound.dart';
import '../services/supabase_service.dart';
import 'track_repository.dart';

/// Supabase를 사용한 TrackRepository 구현체
class SupabaseTrackRepository implements TrackRepository {
  final SupabaseService _supabaseService;
  
  SupabaseTrackRepository(this._supabaseService);
  
  @override
  Future<List<Track>> getAllTracks() async {
    try {
      return await _supabaseService.getTracks();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getAllTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getTracksByCategory(String category) async {
    try {
      final allTracks = await getAllTracks();
      if (category == '전체') {
        return allTracks;
      }
      return allTracks.where((track) => track.category == category).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getTracksByCategory error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getRecommendedTracks() async {
    try {
      final allTracks = await getAllTracks();
      allTracks.shuffle();
      return allTracks.take(3).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getRecommendedTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getTracksByEmotion(String emotion) async {
    try {
      final allTracks = await getAllTracks();
      
      switch (emotion) {
        case 'energy':
          return allTracks
              .where((track) => track.effectKeywords.any((keyword) => 
                  keyword.contains('활력') || keyword.contains('기분전환')))
              .toList();
        case 'stress':
          return allTracks
              .where((track) => track.effectKeywords.any((keyword) => 
                  keyword.contains('이완') || keyword.contains('안정')))
              .toList();
        case 'anxiety':
          return allTracks
              .where((track) => track.effectKeywords.any((keyword) => 
                  keyword.contains('안정') || keyword.contains('긍정')))
              .toList();
        case 'sleep':
          return allTracks
              .where((track) => track.effectKeywords.any((keyword) => 
                  keyword.contains('수면') || keyword.contains('이완')))
              .toList();
        case 'focus':
          return allTracks
              .where((track) => track.effectKeywords.contains('집중'))
              .toList();
        case 'tinnitus':
          return allTracks
              .where((track) => track.effectKeywords.contains('이명케어'))
              .toList();
        default:
          return await getRecommendedTracks();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getTracksByEmotion error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getNatureSoundEffects() async {
    try {
      final allTracks = await getAllTracks();
      return allTracks.where((track) => 
        track.code.startsWith('E') && track.category == '자연음'
      ).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getNatureSoundEffects error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getAsmrTracks() async {
    try {
      return await _supabaseService.getAsmrTracks();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getAsmrTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getTracksByBPMRange(int minBPM, int maxBPM) async {
    try {
      final allTracks = await getAllTracks();
      return allTracks
          .where((track) => track.bpm != null && 
                 track.bpm! >= minBPM && 
                 track.bpm! <= maxBPM)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getTracksByBPMRange error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getSleepTracks() async {
    try {
      final bpmTracks = await getTracksByBPMRange(60, 70);
      return bpmTracks
          .where((track) => track.effectKeywords.contains('수면') || 
                           track.effectKeywords.contains('이완'))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getSleepTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getEnergyTracks() async {
    try {
      final allTracks = await getAllTracks();
      return allTracks
          .where((track) => track.bpm != null && track.bpm! >= 80)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getEnergyTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getMeditationTracks() async {
    try {
      final bpmTracks = await getTracksByBPMRange(60, 80);
      return bpmTracks
          .where((track) => track.effectKeywords.contains('안정') || 
                           track.effectKeywords.contains('집중'))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getMeditationTracks error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<String>> getCategories() async {
    try {
      // 데이터베이스에서 실제 카테고리를 조회하거나, 고정값 반환
      return ['전체', '수면음악', '명상음악', '활력음악'];
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getCategories error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<String>> getEffectKeywordCategories() async {
    try {
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
        print('❌ SupabaseTrackRepository.getEffectKeywordCategories error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Track>> getTracksByEffectKeyword(String keyword) async {
    try {
      final allTracks = await getAllTracks();
      
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
        print('❌ SupabaseTrackRepository.getTracksByEffectKeyword error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<String>> getNatureSounds() async {
    try {
      return [
        '빗소리',
        '파도소리', 
        '새소리',
        '바람소리',
        '시냇물소리',
      ];
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getNatureSounds error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<String>> getEffectKeywords() async {
    try {
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
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getEffectKeywords error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<Track?> getTrackById(int trackId) async {
    try {
      return await _supabaseService.getTrackById(trackId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getTrackById error: $e');
      }
      rethrow;
    }
  }
  
  // === 자연음 전용 메서드 구현 ===
  
  @override
  Future<List<NatureSound>> getAllNatureSounds() async {
    try {
      return await _supabaseService.getNatureSounds();
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getAllNatureSounds error: $e');
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
        print('❌ SupabaseTrackRepository.getActiveNatureSounds error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<NatureSound?> getNatureSoundByCode(String code) async {
    try {
      return await _supabaseService.getNatureSoundByCode(code);
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getNatureSoundByCode error: $e');
      }
      rethrow;
    }
  }
  
  @override
  Future<List<NatureSound>> getNatureSoundsSorted() async {
    try {
      final allSounds = await getActiveNatureSounds();
      allSounds.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return allSounds;
    } catch (e) {
      if (kDebugMode) {
        print('❌ SupabaseTrackRepository.getNatureSoundsSorted error: $e');
      }
      rethrow;
    }
  }
}