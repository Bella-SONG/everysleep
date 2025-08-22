import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/track_feedback.dart';
import '../models/feedback_option.dart';

class FeedbackService {
  static final _client = Supabase.instance.client;

  // 데이터베이스 연결 및 테이블 존재 확인
  static Future<bool> testDatabaseConnection() async {
    try {
      // user_feedback 테이블 존재 확인
      await _client
          .from('user_feedback')
          .select('id')
          .limit(1);
          
      return true;
    } catch (e) {
      return false;
    }
  }

  // 피드백 제출
  static Future<bool> submitFeedback(TrackFeedback feedback) async {
    try {
      final feedbackData = {
        'track_id': int.tryParse(feedback.trackId) ?? feedback.trackId,  // 문자열을 정수로 변환
        'theme_id': feedback.themeId != null ? int.tryParse(feedback.themeId!) : null,  // 테마 ID (정수로 변환)
        'user_id': feedback.userId,
        'rating': feedback.isPositive ? 1 : -1,
        'selected_options': feedback.selectedOptions, // List<String>은 자동으로 jsonb로 변환됨
        'feedback_text': feedback.feedbackText,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      await _client
          .from('user_feedback')
          .insert(feedbackData);

      return true;
    } catch (e) {
      return false;
    }
  }

  // 사용자별 피드백 히스토리 조회
  static Future<List<TrackFeedback>> getUserFeedbackHistory(String userId) async {
    try {
      final response = await _client
          .from('user_feedback')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) => TrackFeedback.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // 트랙별 피드백 통계
  static Future<Map<String, dynamic>?> getTrackFeedbackStats(String trackId) async {
    try {
      // 긍정적 피드백 개수
      final positiveCount = await _client
          .from('user_feedback')
          .select('id')
          .eq('track_id', trackId)
          .eq('rating', 1)
          .count();

      // 부정적 피드백 개수  
      final negativeCount = await _client
          .from('user_feedback')
          .select('id')
          .eq('track_id', trackId)
          .eq('rating', -1)
          .count();

      final total = positiveCount.count + negativeCount.count;
      
      if (total == 0) return null;

      return {
        'track_id': trackId,
        'positive_count': positiveCount.count,
        'negative_count': negativeCount.count,
        'total_count': total,
        'positive_rate': (positiveCount.count / total * 100).round(),
      };
    } catch (e) {
      return null;
    }
  }

  // 사용자가 가장 좋아하는 효과 분석
  static Future<List<Map<String, dynamic>>> getUserPreferredEffects(String userId) async {
    try {
      final response = await _client
          .from('user_feedback')
          .select('feedback_text')
          .eq('user_id', userId)
          .eq('rating', 1);

      // 긍정적 피드백 텍스트를 반환 (user_feedback 테이블에는 selected_options가 없음)
      final Map<String, int> effectCounts = {};
      
      for (final feedback in response) {
        final text = feedback['feedback_text'] ?? '';
        if (text.isNotEmpty) {
          effectCounts[text] = (effectCounts[text] ?? 0) + 1;
        }
      }

      // 개수 순으로 정렬하여 반환
      final sortedEffects = effectCounts.entries
          .map((entry) => {
                'option_id': entry.key,
                'count': entry.value,
                'option_text': _getOptionText(entry.key),
                'icon': _getOptionIcon(entry.key),
              })
          .toList();

      sortedEffects.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      
      return sortedEffects;
    } catch (e) {
      return [];
    }
  }

  // 트랙의 주요 개선점 분석
  static Future<List<Map<String, dynamic>>> getTrackImprovementPoints(String trackId) async {
    try {
      final response = await _client
          .from('user_feedback')
          .select('feedback_text')
          .eq('track_id', trackId)
          .eq('rating', -1);

      // 부정적 피드백 텍스트를 집계 (user_feedback 테이블에는 selected_options가 없음)
      final Map<String, int> issueCounts = {};
      
      for (final feedback in response) {
        final text = feedback['feedback_text'] ?? '';
        if (text.isNotEmpty) {
          issueCounts[text] = (issueCounts[text] ?? 0) + 1;
        }
      }

      // 개수 순으로 정렬하여 반환
      final sortedIssues = issueCounts.entries
          .map((entry) => {
                'option_id': entry.key,
                'count': entry.value,
                'option_text': _getOptionText(entry.key),
                'icon': _getOptionIcon(entry.key),
              })
          .toList();

      sortedIssues.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      
      return sortedIssues;
    } catch (e) {
      return [];
    }
  }

  // 옵션 ID로 텍스트 조회
  static String _getOptionText(String optionId) {
    // 긍정적 옵션들에서 찾기
    for (final option in FeedbackOptions.positiveOptions) {
      if (option.id == optionId) {
        return option.optionText;
      }
    }
    
    // 부정적 옵션들에서 찾기
    for (final option in FeedbackOptions.negativeOptions) {
      if (option.id == optionId) {
        return option.optionText;
      }
    }
    
    return optionId; // 찾지 못한 경우 ID 반환
  }

  // 옵션 ID로 아이콘 조회
  static String _getOptionIcon(String optionId) {
    // 긍정적 옵션들에서 찾기
    for (final option in FeedbackOptions.positiveOptions) {
      if (option.id == optionId) {
        return option.icon;
      }
    }
    
    // 부정적 옵션들에서 찾기
    for (final option in FeedbackOptions.negativeOptions) {
      if (option.id == optionId) {
        return option.icon;
      }
    }
    
    return ''; // 찾지 못한 경우 빈 문자열 반환
  }

  // 전체 앱의 피드백 통계 (관리자용)
  static Future<Map<String, dynamic>?> getOverallFeedbackStats() async {
    try {
      final totalResponse = await _client
          .from('user_feedback')
          .select('id')
          .count();

      final positiveResponse = await _client
          .from('user_feedback')
          .select('id')
          .eq('rating', 1)
          .count();

      final total = totalResponse.count;
      final positive = positiveResponse.count;
      
      if (total == 0) return null;

      return {
        'total_feedback': total,
        'positive_feedback': positive,
        'negative_feedback': total - positive,
        'satisfaction_rate': (positive / total * 100).round(),
      };
    } catch (e) {
      return null;
    }
  }
}