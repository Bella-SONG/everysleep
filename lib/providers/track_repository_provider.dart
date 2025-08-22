import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/track.dart';
import '../models/nature_sound.dart';
import '../repositories/track_repository.dart';
import '../repositories/hybrid_track_repository.dart';

class TrackRepositoryProvider with ChangeNotifier {
  final TrackRepository _repository;
  
  // 로딩 상태 관리
  bool _isLoading = false;
  String? _error;
  
  // 캐시된 데이터들
  List<Track>? _allTracks;
  List<Track>? _recommendedTracks;
  List<String>? _categories;
  
  TrackRepositoryProvider({TrackRepository? repository})
      : _repository = repository ?? HybridTrackRepository();
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Track>? get allTracks => _allTracks;
  List<Track>? get recommendedTracks => _recommendedTracks;
  List<String>? get categories => _categories;
  
  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      // build 중이 아닐 때만 즉시 notifyListeners 호출
      // build 중일 때는 다음 프레임에서 호출
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
  
  /// 에러 상태 설정
  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }
  
  /// 모든 트랙 조회
  Future<List<Track>> getAllTracks({bool forceRefresh = false}) async {
    if (!forceRefresh && _allTracks != null) {
      return _allTracks!;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      final tracks = await _repository.getAllTracks();
      _allTracks = tracks;
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${tracks.length} tracks');
      }
      
      return tracks;
    } catch (e) {
      final errorMessage = 'Failed to load tracks: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getAllTracks: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 카테고리별 트랙 조회
  Future<List<Track>> getTracksByCategory(String category) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final tracks = await _repository.getTracksByCategory(category);
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${tracks.length} tracks for category: $category');
      }
      
      return tracks;
    } catch (e) {
      final errorMessage = 'Failed to load tracks by category: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getTracksByCategory: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 추천 트랙 조회
  Future<List<Track>> getRecommendedTracks({bool forceRefresh = false}) async {
    if (!forceRefresh && _recommendedTracks != null) {
      return _recommendedTracks!;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      final tracks = await _repository.getRecommendedTracks();
      _recommendedTracks = tracks;
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${tracks.length} recommended tracks');
      }
      
      return tracks;
    } catch (e) {
      final errorMessage = 'Failed to load recommended tracks: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getRecommendedTracks: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 감정별 트랙 조회
  Future<List<Track>> getTracksByEmotion(String emotion) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final tracks = await _repository.getTracksByEmotion(emotion);
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${tracks.length} tracks for emotion: $emotion');
      }
      
      return tracks;
    } catch (e) {
      final errorMessage = 'Failed to load tracks by emotion: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getTracksByEmotion: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 자연음 효과음 조회
  Future<List<Track>> getNatureSoundEffects() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final tracks = await _repository.getNatureSoundEffects();
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${tracks.length} nature sound effects');
      }
      
      return tracks;
    } catch (e) {
      final errorMessage = 'Failed to load nature sound effects: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getNatureSoundEffects: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// ASMR 트랙 조회
  Future<List<Track>> getAsmrTracks() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final tracks = await _repository.getAsmrTracks();
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${tracks.length} ASMR tracks');
      }
      
      return tracks;
    } catch (e) {
      final errorMessage = 'Failed to load ASMR tracks: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getAsmrTracks: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 수면용 트랙 조회
  Future<List<Track>> getSleepTracks() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final tracks = await _repository.getSleepTracks();
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${tracks.length} sleep tracks');
      }
      
      return tracks;
    } catch (e) {
      final errorMessage = 'Failed to load sleep tracks: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getSleepTracks: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 활력용 트랙 조회
  Future<List<Track>> getEnergyTracks() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final tracks = await _repository.getEnergyTracks();
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${tracks.length} energy tracks');
      }
      
      return tracks;
    } catch (e) {
      final errorMessage = 'Failed to load energy tracks: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getEnergyTracks: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 명상용 트랙 조회
  Future<List<Track>> getMeditationTracks() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final tracks = await _repository.getMeditationTracks();
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${tracks.length} meditation tracks');
      }
      
      return tracks;
    } catch (e) {
      final errorMessage = 'Failed to load meditation tracks: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getMeditationTracks: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 카테고리 목록 조회
  Future<List<String>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _categories != null) {
      return _categories!;
    }
    
    _setLoading(true);
    _setError(null);
    
    try {
      final categories = await _repository.getCategories();
      _categories = categories;
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${categories.length} categories');
      }
      
      return categories;
    } catch (e) {
      final errorMessage = 'Failed to load categories: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getCategories: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 효과 키워드 카테고리 목록 조회
  Future<List<String>> getEffectKeywordCategories() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final categories = await _repository.getEffectKeywordCategories();
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${categories.length} effect keyword categories');
      }
      
      return categories;
    } catch (e) {
      final errorMessage = 'Failed to load effect keyword categories: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getEffectKeywordCategories: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 효과 키워드별 트랙 조회
  Future<List<Track>> getTracksByEffectKeyword(String keyword) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final tracks = await _repository.getTracksByEffectKeyword(keyword);
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded ${tracks.length} tracks for keyword: $keyword');
      }
      
      return tracks;
    } catch (e) {
      final errorMessage = 'Failed to load tracks by keyword: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getTracksByEffectKeyword: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 특정 트랙 조회
  Future<Track?> getTrackById(int trackId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final track = await _repository.getTrackById(trackId);
      
      if (kDebugMode) {
        print('✅ TrackRepositoryProvider: Loaded track $trackId: ${track?.title}');
      }
      
      return track;
    } catch (e) {
      final errorMessage = 'Failed to load track $trackId: $e';
      _setError(errorMessage);
      
      if (kDebugMode) {
        print('❌ TrackRepositoryProvider.getTrackById: $errorMessage');
      }
      
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 캐시 새로고침
  Future<void> refreshAll() async {
    _allTracks = null;
    _recommendedTracks = null;
    _categories = null;
    
    if (_repository is HybridTrackRepository) {
      await _repository.refreshCache();
    }
    
    // 주요 데이터들 다시 로드
    await Future.wait([
      getAllTracks(forceRefresh: true),
      getRecommendedTracks(forceRefresh: true),
      getCategories(forceRefresh: true),
    ]);
    
    if (kDebugMode) {
      print('🔄 TrackRepositoryProvider: All data refreshed');
    }
  }
  
  /// 에러 클리어
  void clearError() {
    _setError(null);
  }
  
  // === 자연음 관련 메서드들 ===
  
  /// 모든 자연음 조회
  Future<List<NatureSound>> getAllNatureSounds() async {
    _setLoading(true);
    try {
      final sounds = await _repository.getAllNatureSounds();
      _setError(null);
      return sounds;
    } catch (e) {
      _setError('자연음을 불러올 수 없습니다: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 활성화된 자연음만 조회
  Future<List<NatureSound>> getActiveNatureSounds() async {
    _setLoading(true);
    try {
      final sounds = await _repository.getActiveNatureSounds();
      _setError(null);
      return sounds;
    } catch (e) {
      _setError('활성 자연음을 불러올 수 없습니다: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 특정 자연음 조회
  Future<NatureSound?> getNatureSoundByCode(String code) async {
    try {
      final sound = await _repository.getNatureSoundByCode(code);
      _setError(null);
      return sound;
    } catch (e) {
      _setError('자연음 조회 실패: $e');
      rethrow;
    }
  }
  
  /// 자연음 정렬된 순서로 조회
  Future<List<NatureSound>> getNatureSoundsSorted() async {
    _setLoading(true);
    try {
      final sounds = await _repository.getNatureSoundsSorted();
      _setError(null);
      return sounds;
    } catch (e) {
      _setError('자연음 정렬 조회 실패: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}