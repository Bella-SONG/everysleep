class FeedbackOption {
  final String id;
  final FeedbackType type; // positive | negative
  final String optionText; // '잠이 잘 왔어요'
  final String icon; // '😴'
  final int displayOrder;

  const FeedbackOption({
    required this.id,
    required this.type,
    required this.optionText,
    required this.icon,
    required this.displayOrder,
  });

  factory FeedbackOption.fromJson(Map<String, dynamic> json) {
    return FeedbackOption(
      id: json['id'] as String,
      type: FeedbackType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FeedbackType.positive,
      ),
      optionText: json['option_text'] as String,
      icon: json['icon'] as String? ?? '',
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'option_text': optionText,
      'icon': icon,
      'display_order': displayOrder,
    };
  }
}

enum FeedbackType { positive, negative }

class FeedbackOptions {
  // 긍정적 피드백 옵션들 (수면 질 개선, 앱 만족도 통계용)
  static const List<FeedbackOption> positiveOptions = [
    FeedbackOption(
      id: 'sleep_well',
      type: FeedbackType.positive,
      optionText: '잠이 잘 왔어요',
      icon: '😴',
      displayOrder: 1,
    ),
    FeedbackOption(
      id: 'relaxing',
      type: FeedbackType.positive,
      optionText: '마음이 편안해졌어요',
      icon: '😌',
      displayOrder: 2,
    ),
    FeedbackOption(
      id: 'good_mood',
      type: FeedbackType.positive,
      optionText: '기분이 좋아졌어요',
      icon: '😊',
      displayOrder: 3,
    ),
    FeedbackOption(
      id: 'tinnitus_relief',
      type: FeedbackType.positive,
      optionText: '귀가 편해졌어요',
      icon: '👂',
      displayOrder: 4,
    ),
  ];

  // 부정적 피드백 옵션들 (수면 질 개선, 앱 만족도 통계용)
  static const List<FeedbackOption> negativeOptions = [
    FeedbackOption(
      id: 'no_effect',
      type: FeedbackType.negative,
      optionText: '효과를 못 느꼈어요',
      icon: '😐',
      displayOrder: 1,
    ),
    FeedbackOption(
      id: 'too_loud',
      type: FeedbackType.negative,
      optionText: '너무 시끄러웠어요',
      icon: '🔊',
      displayOrder: 2,
    ),
    FeedbackOption(
      id: 'too_quiet',
      type: FeedbackType.negative,
      optionText: '너무 조용했어요',
      icon: '🔇',
      displayOrder: 3,
    ),
    FeedbackOption(
      id: 'music_disappointing',
      type: FeedbackType.negative,
      optionText: '음악이 아쉬워요',
      icon: '🎵',
      displayOrder: 4,
    ),
    FeedbackOption(
      id: 'not_my_taste',
      type: FeedbackType.negative,
      optionText: '제 취향이 아니에요',
      icon: '🤷',
      displayOrder: 5,
    ),
    FeedbackOption(
      id: 'app_inconvenient',
      type: FeedbackType.negative,
      optionText: '앱 이용이 불편했어요',
      icon: '📱',
      displayOrder: 6,
    ),
  ];

  static List<FeedbackOption> getOptions(FeedbackType type) {
    return type == FeedbackType.positive ? positiveOptions : negativeOptions;
  }
}