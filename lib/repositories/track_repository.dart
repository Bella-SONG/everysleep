import '../models/track.dart';
import '../models/nature_sound.dart';

/// 트랙 데이터 접근을 위한 Repository 인터페이스
abstract class TrackRepository {
  /// 모든 트랙 조회
  Future<List<Track>> getAllTracks();
  
  /// 카테고리별 트랙 조회 (기존)
  Future<List<Track>> getTracksByCategory(String category);
  
  /// 효과 키워드별 트랙 조회 (새로운 카테고리 시스템)
  Future<List<Track>> getTracksByEffectKeyword(String keyword);
  
  /// 추천 트랙 조회
  Future<List<Track>> getRecommendedTracks();
  
  /// 감정별 트랙 조회
  Future<List<Track>> getTracksByEmotion(String emotion);
  
  /// 자연음 효과음 조회
  Future<List<Track>> getNatureSoundEffects();
  
  /// ASMR 트랙 조회
  Future<List<Track>> getAsmrTracks();
  
  /// BPM 범위별 트랙 조회
  Future<List<Track>> getTracksByBPMRange(int minBPM, int maxBPM);
  
  /// 수면용 트랙 조회
  Future<List<Track>> getSleepTracks();
  
  /// 활력용 트랙 조회
  Future<List<Track>> getEnergyTracks();
  
  /// 명상용 트랙 조회
  Future<List<Track>> getMeditationTracks();
  
  /// 카테고리 목록 조회 (기존)
  Future<List<String>> getCategories();
  
  /// 효과 키워드 카테고리 목록 조회 (새로운 카테고리 시스템)
  Future<List<String>> getEffectKeywordCategories();
  
  /// 자연음 목록 조회
  Future<List<String>> getNatureSounds();
  
  /// 효과 키워드 목록 조회
  Future<List<String>> getEffectKeywords();
  
  /// 특정 트랙 조회
  Future<Track?> getTrackById(int trackId);
  
  // === 자연음 전용 메서드들 ===
  
  /// 모든 자연음 조회
  Future<List<NatureSound>> getAllNatureSounds();
  
  /// 활성화된 자연음만 조회
  Future<List<NatureSound>> getActiveNatureSounds();
  
  /// 특정 자연음 조회
  Future<NatureSound?> getNatureSoundByCode(String code);
  
  /// 자연음 표시 순서대로 조회
  Future<List<NatureSound>> getNatureSoundsSorted();
}