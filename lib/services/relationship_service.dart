import 'package:flutter/foundation.dart';
import '../models/mood.dart';
import '../models/theme.dart' as app_theme;
import '../models/track.dart';
import 'supabase_service.dart';

/// 데이터베이스의 관계형 구조를 활용하는 서비스
/// 기분-테마-트랙-키워드 간의 관계를 관리
class RelationshipService {
  final SupabaseService _supabaseService = SupabaseService();

  /// 기분에 따른 테마 추천 (theme_moods 관계 테이블 활용)
  Future<List<app_theme.Theme>> getThemesByMood(String moodName) async {
    try {
      if (kDebugMode) {
        print('🔍 RelationshipService: 기분 "$moodName"에 따른 테마 조회');
      }
      
      return await _supabaseService.getThemesByMood(moodName);
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 기분별 테마 조회 실패: $e');
      }
      rethrow;
    }
  }

  /// 테마에 포함된 트랙들 조회 (theme_tracks 관계 테이블 활용)
  Future<List<Track>> getTracksByTheme(app_theme.Theme theme) async {
    try {
      if (kDebugMode) {
        print('🔍 RelationshipService: 테마 "${theme.title}"의 트랙들 조회');
      }
      
      return await _supabaseService.getTracksByTheme(theme);
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 테마별 트랙 조회 실패: $e');
      }
      rethrow;
    }
  }

  /// 키워드에 해당하는 트랙들 조회 (track_keywords 관계 테이블 활용)
  Future<List<Track>> getTracksByKeyword(String keywordName) async {
    try {
      if (kDebugMode) {
        print('🔍 RelationshipService: 키워드 "$keywordName"의 트랙들 조회');
      }
      
      final tracks = await _supabaseService.getTracks();
      return tracks.where((track) => track.hasKeyword(keywordName)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 키워드별 트랙 조회 실패: $e');
      }
      rethrow;
    }
  }

  /// 트랙이 속한 모든 테마들 조회
  Future<List<app_theme.Theme>> getThemesByTrack(Track track) async {
    try {
      if (kDebugMode) {
        print('🔍 RelationshipService: 트랙 "${track.title}"이 속한 테마들 조회');
      }
      
      final allThemes = await _supabaseService.getThemes();
      final matchingThemes = <app_theme.Theme>[];
      
      for (final theme in allThemes) {
        final themeTracks = await getTracksByTheme(theme);
        if (themeTracks.any((t) => t.id == track.id)) {
          matchingThemes.add(theme);
        }
      }
      
      return matchingThemes;
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 트랙별 테마 조회 실패: $e');
      }
      rethrow;
    }
  }

  /// 사용자 기분 기록 저장
  Future<void> logUserMood(String moodName, int? selectedThemeId) async {
    try {
      if (kDebugMode) {
        print('📝 RelationshipService: 사용자 기분 기록 - $moodName');
      }
      
      await _supabaseService.logUserMood(
        await _getMoodIdByName(moodName), 
        selectedThemeId,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 사용자 기분 기록 실패: $e');
      }
      rethrow;
    }
  }

  /// 사용자 재생 기록 저장
  Future<void> logUserPlayback(Track track, int? themeId, int playDurationSeconds, bool completed) async {
    try {
      if (kDebugMode) {
        print('📝 RelationshipService: 재생 기록 - ${track.title}');
      }
      
      // 실제 DB 스키마에 맞는 user_play_logs 삽입 구현 필요
      // await _supabaseService.logUserPlayback(track.id, themeId, playDurationSeconds, completed);
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 재생 기록 실패: $e');
      }
      rethrow;
    }
  }

  /// 사용자 피드백 저장 (좋아요/싫어요)
  Future<void> submitUserFeedback(Track? track, app_theme.Theme? theme, int rating, String? feedbackText) async {
    try {
      if (kDebugMode) {
        print('📝 RelationshipService: 피드백 제출 - 평점: $rating');
      }
      
      // 실제 DB 스키마에 맞는 user_feedback 삽입 구현 필요
      // await _supabaseService.submitUserFeedback(track?.id, theme?.id, rating, feedbackText);
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 피드백 제출 실패: $e');
      }
      rethrow;
    }
  }

  /// 사용자의 최근 기분 기록 조회
  Future<List<Mood>> getUserRecentMoods([int limit = 5]) async {
    try {
      if (kDebugMode) {
        print('🔍 RelationshipService: 사용자 최근 기분 기록 조회');
      }
      
      // 실제 DB에서 user_mood_logs 조회 구현 필요
      return await _supabaseService.getMoods();
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 최근 기분 기록 조회 실패: $e');
      }
      rethrow;
    }
  }

  /// 사용자의 인기 트랙 조회 (재생 기록 기반)
  Future<List<Track>> getUserPopularTracks([int limit = 10]) async {
    try {
      if (kDebugMode) {
        print('🔍 RelationshipService: 사용자 인기 트랙 조회');
      }
      
      // 실제 DB에서 user_play_logs 기반 인기 트랙 조회 구현 필요
      final tracks = await _supabaseService.getTracks();
      return tracks.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 인기 트랙 조회 실패: $e');
      }
      rethrow;
    }
  }

  /// 개인화된 테마 추천 (사용자 기록 기반)
  Future<List<app_theme.Theme>> getPersonalizedThemes([int limit = 3]) async {
    try {
      if (kDebugMode) {
        print('🔍 RelationshipService: 개인화 테마 추천');
      }
      
      // 실제 개인화 알고리즘 구현 필요
      // 1. 사용자의 최근 기분 분석
      // 2. 자주 듣는 트랙의 키워드 분석  
      // 3. 피드백 점수 기반 선호도 분석
      
      final themes = await _supabaseService.getThemes();
      return themes.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 개인화 추천 실패: $e');
      }
      rethrow;
    }
  }

  /// 관련 트랙 추천 (현재 트랙과 유사한 키워드를 가진 트랙들)
  Future<List<Track>> getRelatedTracks(Track currentTrack, [int limit = 5]) async {
    try {
      if (kDebugMode) {
        print('🔍 RelationshipService: "${currentTrack.title}"와 관련된 트랙 추천');
      }
      
      final allTracks = await _supabaseService.getTracks();
      final relatedTracks = <Track>[];
      
      // 같은 키워드를 가진 트랙들 찾기
      for (final track in allTracks) {
        if (track.id == currentTrack.id) continue;
        
        final commonKeywords = track.effectKeywords.toSet()
            .intersection(currentTrack.effectKeywords.toSet());
        
        if (commonKeywords.isNotEmpty) {
          relatedTracks.add(track);
        }
      }
      
      // 공통 키워드 개수로 정렬 후 제한
      relatedTracks.sort((a, b) {
        final aCommon = a.effectKeywords.toSet()
            .intersection(currentTrack.effectKeywords.toSet()).length;
        final bCommon = b.effectKeywords.toSet()
            .intersection(currentTrack.effectKeywords.toSet()).length;
        return bCommon.compareTo(aCommon);
      });
      
      return relatedTracks.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 관련 트랙 추천 실패: $e');
      }
      rethrow;
    }
  }

  /// 데이터베이스 관계 통계 조회
  Future<Map<String, dynamic>> getRelationshipStats() async {
    try {
      if (kDebugMode) {
        print('🔍 RelationshipService: 관계 통계 조회');
      }
      
      final summary = await _supabaseService.getDataSummary();
      
      return {
        'themes': summary['themes'] ?? 0,
        'tracks': summary['tracks'] ?? 0, 
        'moods': summary['moods'] ?? 0,
        'keywords': summary['keywords'] ?? 0,
        'theme_mood_relations': summary['theme_moods'] ?? 0,
        'theme_track_relations': summary['theme_tracks'] ?? 0,
        'track_keyword_relations': summary['track_keywords'] ?? 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ RelationshipService: 관계 통계 조회 실패: $e');
      }
      rethrow;
    }
  }

  // Helper methods
  Future<int> _getMoodIdByName(String moodName) async {
    final moods = await _supabaseService.getMoods();
    final mood = moods.firstWhere((m) => m.name == moodName);
    return mood.id;
  }
}