import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/track.dart';
import '../models/theme.dart';
import '../models/mood.dart';
import '../models/nature_sound.dart';

class SupabaseService {
  // 싱글톤 패턴
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _client = Supabase.instance.client;

  /// 데이터베이스 연결 상태 확인
  Future<bool> testConnection() async {
    try {
      if (kDebugMode) {
        print('🔍 SupabaseService: 연결 테스트 시작');
      }
      
      // 간단한 테이블 접근 테스트
      await _client
          .from('moods')
          .select('id')
          .limit(1);
      
      if (kDebugMode) {
        print('✅ 연결 테스트 성공 - moods 테이블 접근 가능');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 연결 테스트 실패: $e');
      }
      return false;
    }
  }

  // ======================== MOODS ========================

  /// 모든 기분 조회 (display_order 순으로 정렬)
  Future<List<Mood>> getMoods() async {
    try {
      if (kDebugMode) {
        print('🔍 SupabaseService: getMoods() 시작');
        print('🔑 Auth 상태: ${_client.auth.currentUser?.id ?? "anonymous"}');
      }

      final response = await _client
          .from('moods')
          .select()
          .order('display_order');

      if (kDebugMode) {
        print('✅ Moods raw response: $response');
        print('✅ Moods fetched: ${response.length} items');
        if (response.isNotEmpty) {
          print('📋 첫 번째 mood: ${response.first}');
        }
      }

      return response.map<Mood>((json) => Mood.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching moods: $e');
        print('❌ Error type: ${e.runtimeType}');
        if (e is PostgrestException) {
          print('❌ Postgrest error code: ${e.code}');
          print('❌ Postgrest error message: ${e.message}');
          print('❌ Postgrest error details: ${e.details}');
        }
      }
      rethrow;
    }
  }

  // ======================== THEMES ========================

  /// 모든 테마 조회 (display_order 순으로 정렬)
  Future<List<Theme>> getThemes() async {
    try {
      final response = await _client
          .from('themes')
          .select('''
            *,
            tracks:theme_tracks(
              tracks(code, title)
            )
          ''')
          .order('display_order');

      if (kDebugMode) {
        print('✅ Themes fetched: ${response.length} items');
        for (var theme in response) {
          print('Theme: ${theme['title']}, Tracks: ${theme['tracks']?.length ?? 0}');
        }
      }

      return response.map<Theme>((json) => Theme.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching themes: $e');
      }
      rethrow;
    }
  }

  /// 특정 기분에 맞는 테마 조회 (정규화된 관계 테이블 사용)
  Future<List<Theme>> getThemesByMood(String moodName) async {
    try {
      // 1. 기분 이름으로 mood_id 찾기
      if (kDebugMode) {
        print('🔍 Searching for mood: "$moodName"');
      }
      
      final moodResponse = await _client
          .from('moods')
          .select('id')
          .eq('name', moodName)
          .maybeSingle();

      if (moodResponse == null) {
        if (kDebugMode) {
          print('❌ Mood not found: "$moodName"');
          // 모든 mood 출력해서 데이터 확인
          final allMoods = await _client.from('moods').select('id, name');
          print('📋 Available moods in database:');
          for (var mood in allMoods) {
            print('   - ID: ${mood['id']}, Name: "${mood['name']}"');
          }
        }
        return [];
      }

      final moodId = moodResponse['id'] as int;
      if (kDebugMode) {
        print('✅ Found mood ID: $moodId for "$moodName"');
      }

      // 2. 먼저 관련된 theme_id들 가져오기
      final themeIds = await _getThemeIdsByMood(moodId);
      
      if (kDebugMode) {
        print('🎯 Theme IDs for mood_id $moodId: $themeIds');
      }
      
      if (themeIds.isEmpty) {
        if (kDebugMode) {
          print('❌ No theme IDs found for mood_id $moodId');
        }
        return [];
      }

      // 3. 해당 테마들 기본 정보만 조회 (조인 제거)
      final response = await _client
          .from('themes')
          .select('*')
          .inFilter('id', themeIds)
          .order('display_order');

      if (kDebugMode) {
        print('✅ Themes for mood "$moodName": ${response.length} items');
        if (response.isEmpty) {
          // theme_moods 테이블 확인
          final themeMoods = await _client
              .from('theme_moods')
              .select('theme_id, mood_id')
              .eq('mood_id', moodId);
          print('📋 theme_moods relationships for mood_id $moodId:');
          for (var relation in themeMoods) {
            print('   - theme_id: ${relation['theme_id']}, mood_id: ${relation['mood_id']}');
          }
        }
        for (var theme in response) {
          print('   - Theme: ${theme['title']}');
        }
      }

      // 4. 각 테마의 트랙 개수를 별도로 조회하여 추가
      List<Theme> themes = [];
      for (var themeData in response) {
        // 트랙 개수 조회
        final trackCountResponse = await _client
            .from('theme_tracks')
            .select('track_id')
            .eq('theme_id', themeData['id']);
        
        // trackIds 배열을 빈 배열로 초기화 (정규화된 구조에서는 별도 관리)
        themeData['track_ids'] = [];
        themeData['track_count'] = trackCountResponse.length;
        themeData['moods'] = []; // 기본값
        
        themes.add(Theme.fromJson(themeData));
      }
      
      return themes;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching themes by mood: $e');
      }
      rethrow;
    }
  }

  /// 테마 ID로 단일 테마 조회
  Future<Theme?> getThemeById(int themeId) async {
    try {
      final response = await _client
          .from('themes')
          .select()
          .eq('id', themeId)
          .maybeSingle();

      if (response == null) return null;

      if (kDebugMode) {
        print('✅ Theme fetched: $themeId');
      }

      return Theme.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching theme $themeId: $e');
      }
      return null;
    }
  }

  /// 특정 mood_id에 연결된 theme_id들을 조회하는 헬퍼 메서드
  Future<List<int>> _getThemeIdsByMood(int moodId) async {
    if (kDebugMode) {
      print('🔍 Looking for theme_ids where mood_id = $moodId');
    }
    
    final response = await _client
        .from('theme_moods')
        .select('theme_id')
        .eq('mood_id', moodId);
    
    if (kDebugMode) {
      print('📊 theme_moods query result: $response');
    }
    
    final themeIds = response.map<int>((row) => row['theme_id'] as int).toList();
    
    if (kDebugMode) {
      print('🎯 Extracted theme_ids: $themeIds');
    }
    
    return themeIds;
  }

  // ======================== TRACKS ========================

  /// 모든 트랙 조회 (display_order 순으로 정렬)
  Future<List<Track>> getTracks() async {
    try {
      final response = await _client
          .from('track_details')
          .select()
          .order('display_order');

      if (kDebugMode) {
        print('✅ Tracks fetched: ${response.length} items');
        if (response.isNotEmpty) {
          print('📋 첫 번째 track: ${response.first}');
        }
      }

      return response.map<Track>((json) => Track.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching tracks: $e');
      }
      rethrow;
    }
  }

  /// 특정 테마에 포함된 트랙들 조회 (정규화된 관계 테이블 사용)
  Future<List<Track>> getTracksByThemeId(int themeId) async {
    try {
      // 먼저 theme_tracks에서 정렬된 track_id들을 가져오기
      final themeTracksResponse = await _client
          .from('theme_tracks')
          .select('track_id, display_order')
          .eq('theme_id', themeId)
          .order('display_order');

      if (themeTracksResponse.isEmpty) {
        if (kDebugMode) {
          print('❌ No tracks found for theme $themeId');
        }
        return [];
      }

      // track_id 순서를 유지하면서 tracks 조회
      final trackIds = themeTracksResponse.map((item) => item['track_id']).toList();
      
      final tracksResponse = await _client
          .from('tracks')
          .select()
          .inFilter('id', trackIds);

      if (kDebugMode) {
        print('✅ Tracks for theme $themeId: ${tracksResponse.length} items');
      }

      // display_order 순서대로 정렬
      final tracks = tracksResponse.map<Track>((json) => Track.fromJson(json)).toList();
      
      // theme_tracks의 display_order에 따라 수동 정렬
      tracks.sort((a, b) {
        final aIndex = trackIds.indexOf(a.id);
        final bIndex = trackIds.indexOf(b.id);
        return aIndex.compareTo(bIndex);
      });

      return tracks;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching tracks by theme: $e');
      }
      rethrow;
    }
  }

  /// Theme 객체로 트랙들 조회 (호환성 유지)
  Future<List<Track>> getTracksByTheme(Theme theme) async {
    return await getTracksByThemeId(theme.id);
  }

  /// 트랙 ID로 단일 트랙 조회
  Future<Track?> getTrackById(int trackId) async {
    try {
      final response = await _client
          .from('tracks')
          .select()
          .eq('id', trackId)
          .maybeSingle();

      if (response == null) return null;

      if (kDebugMode) {
        print('✅ Track fetched: $trackId');
      }

      return Track.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching track $trackId: $e');
      }
      return null;
    }
  }

  /// 키워드로 트랙 검색 (정규화된 관계 테이블 사용)
  Future<List<Track>> searchTracksByKeyword(String keyword) async {
    try {
      final response = await _client
          .from('tracks')
          .select('''
            *,
            track_keywords!inner(
              keywords!inner(name)
            )
          ''')
          .ilike('track_keywords.keywords.name', '%$keyword%')
          .order('display_order');

      if (kDebugMode) {
        print('✅ Tracks searched by keyword "$keyword": ${response.length} items');
      }

      return response.map<Track>((json) => Track.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching tracks by keyword: $e');
      }
      rethrow;
    }
  }

  /// ASMR 트랙만 조회
  Future<List<Track>> getAsmrTracks() async {
    try {
      final response = await _client
          .from('tracks')
          .select()
          .eq('is_asmr', true)
          .order('display_order');

      if (kDebugMode) {
        print('✅ ASMR tracks fetched: ${response.length} items');
      }

      return response.map<Track>((json) => Track.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching ASMR tracks: $e');
      }
      rethrow;
    }
  }

  // ======================== USER ANALYTICS ========================

  /// 사용자 기분 기록 저장
  Future<void> logUserMood(int moodId, int? selectedThemeId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _client.from('user_mood_logs').insert({
        'user_id': user.id,
        'mood_id': moodId,
        'selected_theme_id': selectedThemeId,
      });

      if (kDebugMode) {
        print('✅ User mood logged: $moodId -> $selectedThemeId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging user mood: $e');
      }
      rethrow;
    }
  }

  /// 사용자 재생 기록 저장
  Future<void> logUserPlay({
    required int trackId,
    int? themeId,
    int? playDurationSeconds,
    bool completed = false,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _client.from('user_play_logs').insert({
        'user_id': user.id,
        'track_id': trackId,
        'theme_id': themeId,
        'play_duration_seconds': playDurationSeconds,
        'completed': completed,
      });

      if (kDebugMode) {
        print('✅ User play logged: track=$trackId, duration=${playDurationSeconds}s');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging user play: $e');
      }
      rethrow;
    }
  }

  /// 사용자 피드백 저장 (좋아요/싫어요)
  Future<void> logUserFeedback({
    int? trackId,
    int? themeId,
    required int rating, // 1: 좋아요, -1: 싫어요
    String? feedbackText,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _client.from('user_feedback').insert({
        'user_id': user.id,
        'track_id': trackId,
        'theme_id': themeId,
        'rating': rating,
        'feedback_text': feedbackText,
      });

      if (kDebugMode) {
        print('✅ User feedback logged: rating=$rating');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error logging user feedback: $e');
      }
      rethrow;
    }
  }

  // ======================== UTILITY METHODS ========================

  /// 전체 데이터 요약 조회
  Future<Map<String, int>> getDataSummary() async {
    try {
      final themesResponse = await _client.from('themes').select('id');
      final tracksResponse = await _client.from('tracks').select('id');
      final moodsResponse = await _client.from('moods').select('id');

      final summary = {
        'themes': themesResponse.length,
        'tracks': tracksResponse.length,
        'moods': moodsResponse.length,
      };

      if (kDebugMode) {
        print('✅ Data summary: $summary');
      }

      return summary;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting data summary: $e');
      }
      return {'themes': 0, 'tracks': 0, 'moods': 0};
    }
  }
  
  // ======================== NATURE SOUNDS ========================
  
  /// 모든 자연음 조회
  Future<List<NatureSound>> getNatureSounds() async {
    try {
      if (kDebugMode) {
        print('🔍 SupabaseService: getNatureSounds() 시작');
      }
      
      final response = await _client
          .from('nature_sounds')
          .select('*')
          .order('display_order');
      
      if (kDebugMode) {
        print('✅ 자연음 ${response.length}개 조회 성공');
      }
      
      return response.map((json) => NatureSound.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ getNatureSounds 오류: $e');
      }
      rethrow;
    }
  }
  
  /// 특정 코드로 자연음 조회
  Future<NatureSound?> getNatureSoundByCode(String code) async {
    try {
      if (kDebugMode) {
        print('🔍 SupabaseService: getNatureSoundByCode($code) 시작');
      }
      
      final response = await _client
          .from('nature_sounds')
          .select('*')
          .eq('code', code)
          .maybeSingle();
      
      if (response == null) {
        if (kDebugMode) {
          print('⚠️ 자연음 코드 $code를 찾을 수 없음');
        }
        return null;
      }
      
      if (kDebugMode) {
        print('✅ 자연음 코드 $code 조회 성공');
      }
      
      return NatureSound.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ getNatureSoundByCode 오류: $e');
      }
      rethrow;
    }
  }
}