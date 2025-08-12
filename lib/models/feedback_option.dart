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
  // 긍정적 피드백 옵션들
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
      id: 'focused',
      type: FeedbackType.positive,
      optionText: '집중이 잘됐어요',
      icon: '🎯',
      displayOrder: 3,
    ),
    FeedbackOption(
      id: 'stress_relief',
      type: FeedbackType.positive,
      optionText: '스트레스가 줄었어요',
      icon: '😮‍💨',
      displayOrder: 4,
    ),
    FeedbackOption(
      id: 'good_mood',
      type: FeedbackType.positive,
      optionText: '기분이 좋아졌어요',
      icon: '😊',
      displayOrder: 5,
    ),
    FeedbackOption(
      id: 'body_relaxed',
      type: FeedbackType.positive,
      optionText: '몸이 이완됐어요',
      icon: '🧘',
      displayOrder: 6,
    ),
    FeedbackOption(
      id: 'tinnitus_relief',
      type: FeedbackType.positive,
      optionText: '귀가 편안해졌어요',
      icon: '👂',
      displayOrder: 7,
    ),
  ];

  // 부정적 피드백 옵션들
  static const List<FeedbackOption> negativeOptions = [
    FeedbackOption(
      id: 'no_sleep',
      type: FeedbackType.negative,
      optionText: '잠이 안 왔어요',
      icon: '😵',
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
      id: 'boring',
      type: FeedbackType.negative,
      optionText: '지루했어요',
      icon: '😑',
      displayOrder: 3,
    ),
    FeedbackOption(
      id: 'no_focus',
      type: FeedbackType.negative,
      optionText: '집중이 안됐어요',
      icon: '🌀',
      displayOrder: 4,
    ),
    FeedbackOption(
      id: 'anxious',
      type: FeedbackType.negative,
      optionText: '불안해졌어요',
      icon: '😰',
      displayOrder: 5,
    ),
    FeedbackOption(
      id: 'bad_quality',
      type: FeedbackType.negative,
      optionText: '음질이 좋지 않았어요',
      icon: '📻',
      displayOrder: 6,
    ),
    FeedbackOption(
      id: 'wrong_length',
      type: FeedbackType.negative,
      optionText: '길이가 적당하지 않았어요',
      icon: '⏰',
      displayOrder: 7,
    ),
    FeedbackOption(
      id: 'not_my_taste',
      type: FeedbackType.negative,
      optionText: '제 취향이 아니에요',
      icon: '🤷',
      displayOrder: 8,
    ),
  ];

  static List<FeedbackOption> getOptions(FeedbackType type) {
    return type == FeedbackType.positive ? positiveOptions : negativeOptions;
  }
}