import 'package:flutter/foundation.dart';
import '../models/theme.dart';
import '../models/track.dart';
import '../services/supabase_service.dart';
import '../repositories/track_repository.dart';
import '../repositories/hybrid_track_repository.dart';

class ThemeProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final TrackRepository _trackRepository = HybridTrackRepository();

  // State
  List<Theme> _themes = [];
  List<Track> _allTracks = [];
  Theme? _selectedTheme;
  List<Track> _selectedThemeTracks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Theme> get themes => _themes;
  List<Track> get allTracks => _allTracks;
  Theme? get selectedTheme => _selectedTheme;
  List<Track> get selectedThemeTracks => _selectedThemeTracks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _themes.isNotEmpty && _allTracks.isNotEmpty;

  // 초기 데이터 로드
  Future<void> initialize() async {
    await loadThemes();
    await loadAllTracks();
  }

  // 모든 테마 로드
  Future<void> loadThemes() async {
    try {
      _setLoading(true);
      _themes = await _supabaseService.getThemes();
      _error = null;
      
      if (kDebugMode) {
        print('✅ ThemeProvider: ${_themes.length} themes loaded');
      }
    } catch (e) {
      _error = '테마를 불러오는데 실패했습니다: $e';
      if (kDebugMode) {
        print('❌ ThemeProvider error loading themes: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // 모든 트랙 로드 (Repository 사용으로 일관성 확보)
  Future<void> loadAllTracks() async {
    try {
      _setLoading(true);
      // TrackRepository를 사용하여 홈화면과 추천음악 탭의 데이터 소스 통일
      _allTracks = await _trackRepository.getAllTracks();
      _error = null;
      
      if (kDebugMode) {
        print('✅ ThemeProvider: ${_allTracks.length} tracks loaded via Repository');
      }
    } catch (e) {
      _error = '트랙을 불러오는데 실패했습니다: $e';
      if (kDebugMode) {
        print('❌ ThemeProvider error loading tracks: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // 특정 기분으로 테마 필터링
  Future<List<Theme>> getThemesByMood(String mood) async {
    try {
      return await _supabaseService.getThemesByMood(mood);
    } catch (e) {
      if (kDebugMode) {
        print('❌ ThemeProvider error filtering themes by mood: $e');
      }
      return _themes.where((theme) => theme.containsMood(mood)).toList();
    }
  }

  // 테마 선택 및 해당 트랙들 로드
  Future<void> selectTheme(Theme theme) async {
    try {
      _selectedTheme = theme;
      _setLoading(true);
      
      // 먼저 전체 트랙이 로드되어 있는지 확인
      if (_allTracks.isEmpty) {
        await loadAllTracks();
      }
      
      // 테마에 포함된 트랙들을 Repository에서 가져온 데이터에서 필터링
      // 이렇게 하면 홈화면과 추천음악 탭이 동일한 데이터를 사용
      final themeTrackIds = await _supabaseService.getTracksByTheme(theme);
      final themeTrackIdSet = themeTrackIds.map((t) => t.id).toSet();
      
      _selectedThemeTracks = _allTracks.where((track) => 
        themeTrackIdSet.contains(track.id)
      ).toList();
      
      // 만약 Repository에서 못 찾으면 DB에서 직접 가져온 것 사용
      if (_selectedThemeTracks.isEmpty && themeTrackIds.isNotEmpty) {
        _selectedThemeTracks = themeTrackIds;
      }
      
      _error = null;
      
      if (kDebugMode) {
        print('✅ ThemeProvider: Theme "${theme.title}" selected with ${_selectedThemeTracks.length} tracks');
      }
    } catch (e) {
      _error = '테마 트랙을 불러오는데 실패했습니다: $e';
      if (kDebugMode) {
        print('❌ ThemeProvider error loading theme tracks: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // 테마 선택 해제
  void clearSelection() {
    _selectedTheme = null;
    _selectedThemeTracks = [];
    notifyListeners();
  }

  // 트랙 검색 (키워드 기반)
  List<Track> searchTracks(String query) {
    if (query.isEmpty) return _allTracks;
    
    final lowercaseQuery = query.toLowerCase();
    return _allTracks.where((track) {
      return track.title.toLowerCase().contains(lowercaseQuery) ||
             track.artist.toLowerCase().contains(lowercaseQuery) ||
             track.description?.toLowerCase().contains(lowercaseQuery) == true ||
             track.effectKeywords.any((keyword) => 
                 keyword.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // 특정 키워드로 트랙 필터링
  List<Track> getTracksByKeyword(String keyword) {
    return _allTracks.where((track) => track.hasKeyword(keyword)).toList();
  }

  // ASMR 트랙만 가져오기
  List<Track> getAsmrTracks() {
    return _allTracks.where((track) => track.isAsmr).toList();
  }

  // 수면용 트랙 가져오기
  List<Track> getSleepTracks() {
    return _allTracks.where((track) => 
        track.hasKeyword('수면') || track.hasKeyword('이완')).toList();
  }

  // 활력용 트랙 가져오기
  List<Track> getEnergyTracks() {
    return _allTracks.where((track) => 
        track.hasKeyword('활력') || track.hasKeyword('기분전환')).toList();
  }

  // 특정 테마에서 트랙 찾기
  Theme? findThemeByTrack(Track track) {
    return _themes.firstWhere(
      (theme) => theme.trackIds.contains(track.id.toString()),
      orElse: () => null as dynamic,
    );
  }

  // 데이터 새로고침
  Future<void> refresh() async {
    await Future.wait([
      loadThemes(),
      loadAllTracks(),
    ]);
  }

  // 연결 테스트
  Future<bool> testConnection() async {
    try {
      return await _supabaseService.testConnection();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ThemeProvider connection test failed: $e');
      }
      return false;
    }
  }

  // 데이터 요약 정보
  Future<Map<String, int>> getDataSummary() async {
    try {
      return await _supabaseService.getDataSummary();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ThemeProvider error getting data summary: $e');
      }
      return {'themes': _themes.length, 'tracks': _allTracks.length};
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 에러 클리어
  void clearError() {
    _error = null;
    notifyListeners();
  }

}