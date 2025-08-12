class TrackFeedback {
  final String? id;
  final String trackId;
  final String? themeId; // 테마 ID (선택사항)
  final String userId;
  final bool isPositive; // true=👍, false=👎
  final List<String> selectedOptions; // 선택한 옵션 ID들
  final String? feedbackText; // 자유 입력 텍스트
  final DateTime createdAt;

  TrackFeedback({
    this.id,
    required this.trackId,
    this.themeId,
    required this.userId,
    required this.isPositive,
    required this.selectedOptions,
    this.feedbackText,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TrackFeedback.now({
    this.id,
    required this.trackId,
    this.themeId,
    required this.userId,
    required this.isPositive,
    required this.selectedOptions,
    this.feedbackText,
  }) : createdAt = DateTime.now();

  factory TrackFeedback.fromJson(Map<String, dynamic> json) {
    return TrackFeedback(
      id: json['id'] as String?,
      trackId: json['track_id']?.toString() ?? '',
      themeId: json['theme_id']?.toString(),
      userId: json['user_id'] as String,
      isPositive: (json['rating'] as int?) == 1,
      selectedOptions: [], // user_feedback 테이블에는 selected_options가 없음
      feedbackText: json['feedback_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'track_id': trackId,
      'theme_id': themeId,
      'user_id': userId,
      'is_positive': isPositive,
      'selected_options': selectedOptions,
      'feedback_text': feedbackText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TrackFeedback copyWith({
    String? id,
    String? trackId,
    String? userId,
    bool? isPositive,
    List<String>? selectedOptions,
    String? feedbackText,
    DateTime? createdAt,
  }) {
    return TrackFeedback(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      userId: userId ?? this.userId,
      isPositive: isPositive ?? this.isPositive,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      feedbackText: feedbackText ?? this.feedbackText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}