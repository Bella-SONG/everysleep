import 'package:flutter/foundation.dart';
import '../models/track.dart';
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
}