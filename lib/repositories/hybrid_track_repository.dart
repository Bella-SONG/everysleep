import 'package:flutter/foundation.dart';
import '../models/track.dart';
import '../models/nature_sound.dart';
import '../config/app_config.dart';
import '../services/supabase_service.dart';
import 'track_repository.dart';
import 'supabase_track_repository.dart';
import 'sample_track_repository.dart';

/// 환경에 따라 데이터 소스를 자동 선택하고 fallback을 지원하는 Repository
class HybridTrackRepository implements TrackRepository {
  final SupabaseTrackRepository _supabaseRepository;
  final SampleTrackRepository _sampleRepository;
  
  // 캐시된 데이터
  List<Track>? _cachedTracks;
  DateTime? _cacheTimestamp;
  
  HybridTrackRepository()
      : _supabaseRepository = SupabaseTrackRepository(SupabaseService()),
        _sampleRepository = SampleTrackRepository();
  
  /// 캐시가 유효한지 확인
  bool _isCacheValid() {
    if (_cachedTracks == null || _cacheTimestamp == null) return false;
    
    final now = DateTime.now();
    final expirationTime = _cacheTimestamp!.add(
      Duration(minutes: AppConfig.cacheExpirationMinutes)
    );
    
    return now.isBefore(expirationTime);
  }
  
  /// 데이터 소스 선택 (환경 및 네트워크 상태에 따라)
  TrackRepository _selectRepository() {
    if (AppConfig.useLocalData) {
      if (kDebugMode) {
        print('🔧 Using SampleTrackRepository (local data mode)');
      }
      return _sampleRepository;
    } else {
      if (kDebugMode) {
        print('🔧 Using SupabaseTrackRepository (database mode)');
      }
      return _supabaseRepository;
    }
  }
  
  /// Fallback을 지원하는 데이터 조회 메서드
  Future<T> _executeWithFallback<T>(
    Future<T> Function(TrackRepository) primaryOperation,
    Future<T> Function(TrackRepository) fallbackOperation,
  ) async {
    final primaryRepo = _selectRepository();
    final fallbackRepo = AppConfig.useLocalData ? _supabaseRepository : _sampleRepository;
    
    for (int attempt = 0; attempt < AppConfig.maxRetryAttempts; attempt++) {
      try {
        if (kDebugMode) {
          print('🔍 Attempt ${attempt + 1} with primary repository');
        }
        
        final result = await primaryOperation(primaryRepo).timeout(
          Duration(seconds: AppConfig.requestTimeoutSeconds)
        );
        
        if (kDebugMode) {
          print('✅ Primary repository succeeded');
        }
        return result;
        
      } catch (e) {
        if (kDebugMode) {
          print('❌ Primary repository failed (attempt ${attempt + 1}): $e');
        }
        
        // 마지막 시도에서 실패하면 fallback 사용
        if (attempt == AppConfig.maxRetryAttempts - 1) {
          try {
            if (kDebugMode) {
              print('🔄 Trying fallback repository');
            }
            
            final fallbackResult = await fallbackOperation(fallbackRepo);
            
            if (kDebugMode) {
              print('✅ Fallback repository succeeded');
            }
            return fallbackResult;
            
          } catch (fallbackError) {
            if (kDebugMode) {
              print('❌ Fallback repository also failed: $fallbackError');
            }
            rethrow;
          }
        }
        
        // 재시도 전 약간의 지연
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
    
    throw Exception('All attempts failed');
  }
  
  @override
  Future<List<Track>> getAllTracks() async {
    // 캐시 확인
    if (_isCacheValid()) {
      if (kDebugMode) {
        print('📦 Returning cached tracks');
      }
      return _cachedTracks!;
    }
    
    final tracks = await _executeWithFallback<List<Track>>(
      (repo) => repo.getAllTracks(),
      (repo) => repo.getAllTracks(),
    );
    
    // 캐시 업데이트
    _cachedTracks = tracks;
    _cacheTimestamp = DateTime.now();
    
    return tracks;
  }
  
  @override
  Future<List<Track>> getTracksByCategory(String category) async {
    return await _executeWithFallback<List<Track>>(
      (repo) => repo.getTracksByCategory(category),
      (repo) => repo.getTracksByCategory(category),
    );
  }
  
  @override
  Future<List<Track>> getRecommendedTracks() async {
    return await _executeWithFallback<List<Track>>(
      (repo) => repo.getRecommendedTracks(),
      (repo) => repo.getRecommendedTracks(),
    );
  }
  
  @override
  Future<List<Track>> getTracksByEmotion(String emotion) async {
    return await _executeWithFallback<List<Track>>(
      (repo) => repo.getTracksByEmotion(emotion),
      (repo) => repo.getTracksByEmotion(emotion),
    );
  }
  
  @override
  Future<List<Track>> getNatureSoundEffects() async {
    return await _executeWithFallback<List<Track>>(
      (repo) => repo.getNatureSoundEffects(),
      (repo) => repo.getNatureSoundEffects(),
    );
  }
  
  @override
  Future<List<Track>> getAsmrTracks() async {
    return await _executeWithFallback<List<Track>>(
      (repo) => repo.getAsmrTracks(),
      (repo) => repo.getAsmrTracks(),
    );
  }
  
  @override
  Future<List<Track>> getTracksByBPMRange(int minBPM, int maxBPM) async {
    return await _executeWithFallback<List<Track>>(
      (repo) => repo.getTracksByBPMRange(minBPM, maxBPM),
      (repo) => repo.getTracksByBPMRange(minBPM, maxBPM),
    );
  }
  
  @override
  Future<List<Track>> getSleepTracks() async {
    return await _executeWithFallback<List<Track>>(
      (repo) => repo.getSleepTracks(),
      (repo) => repo.getSleepTracks(),
    );
  }
  
  @override
  Future<List<Track>> getEnergyTracks() async {
    return await _executeWithFallback<List<Track>>(
      (repo) => repo.getEnergyTracks(),
      (repo) => repo.getEnergyTracks(),
    );
  }
  
  @override
  Future<List<Track>> getMeditationTracks() async {
    return await _executeWithFallback<List<Track>>(
      (repo) => repo.getMeditationTracks(),
      (repo) => repo.getMeditationTracks(),
    );
  }
  
  @override
  Future<List<String>> getCategories() async {
    return await _executeWithFallback<List<String>>(
      (repo) => repo.getCategories(),
      (repo) => repo.getCategories(),
    );
  }
  
  @override
  Future<List<String>> getEffectKeywordCategories() async {
    return await _executeWithFallback<List<String>>(
      (repo) => repo.getEffectKeywordCategories(),
      (repo) => repo.getEffectKeywordCategories(),
    );
  }
  
  @override
  Future<List<Track>> getTracksByEffectKeyword(String keyword) async {
    return await _executeWithFallback<List<Track>>(
      (repo) => repo.getTracksByEffectKeyword(keyword),
      (repo) => repo.getTracksByEffectKeyword(keyword),
    );
  }
  
  @override
  Future<List<String>> getNatureSounds() async {
    return await _executeWithFallback<List<String>>(
      (repo) => repo.getNatureSounds(),
      (repo) => repo.getNatureSounds(),
    );
  }
  
  @override
  Future<List<String>> getEffectKeywords() async {
    return await _executeWithFallback<List<String>>(
      (repo) => repo.getEffectKeywords(),
      (repo) => repo.getEffectKeywords(),
    );
  }
  
  @override
  Future<Track?> getTrackById(int trackId) async {
    return await _executeWithFallback<Track?>(
      (repo) => repo.getTrackById(trackId),
      (repo) => repo.getTrackById(trackId),
    );
  }
  
  /// 캐시 강제 새로고침
  Future<void> refreshCache() async {
    _cachedTracks = null;
    _cacheTimestamp = null;
    await getAllTracks(); // 새로운 데이터 로드 및 캐시
  }
  
  /// 캐시 클리어
  void clearCache() {
    _cachedTracks = null;
    _cacheTimestamp = null;
    if (kDebugMode) {
      print('🗑️ Cache cleared');
    }
  }
  
  // === 자연음 전용 메서드 구현 ===
  
  @override
  Future<List<NatureSound>> getAllNatureSounds() async {
    return await _executeWithFallback<List<NatureSound>>(
      (repo) => repo.getAllNatureSounds(),
      (repo) => repo.getAllNatureSounds(),
    );
  }
  
  @override
  Future<List<NatureSound>> getActiveNatureSounds() async {
    return await _executeWithFallback<List<NatureSound>>(
      (repo) => repo.getActiveNatureSounds(),
      (repo) => repo.getActiveNatureSounds(),
    );
  }
  
  @override
  Future<NatureSound?> getNatureSoundByCode(String code) async {
    return await _executeWithFallback<NatureSound?>(
      (repo) => repo.getNatureSoundByCode(code),
      (repo) => repo.getNatureSoundByCode(code),
    );
  }
  
  @override
  Future<List<NatureSound>> getNatureSoundsSorted() async {
    return await _executeWithFallback<List<NatureSound>>(
      (repo) => repo.getNatureSoundsSorted(),
      (repo) => repo.getNatureSoundsSorted(),
    );
  }
}