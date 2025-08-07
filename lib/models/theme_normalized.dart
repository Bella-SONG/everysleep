import 'mood.dart';
import 'track_normalized.dart';

class ThemeNormalized {
  final int id;
  final String code; // 기존 'theme_1' 같은 코드
  final String title;
  final String subtitle;
  final String description;
  final String? iconPath;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 관계 데이터 (JOIN 결과)
  final List<Mood> moods;
  final List<TrackNormalized> tracks;

  ThemeNormalized({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.description,
    this.iconPath,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
    this.moods = const [],
    this.tracks = const [],
  });

  factory ThemeNormalized.fromJson(Map<String, dynamic> json) {
    return ThemeNormalized(
      id: json['id'] as int,
      code: json['code'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      iconPath: json['icon_path'] as String?,
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // 관계 데이터는 별도로 로드
    );
  }

  // theme_details 뷰에서 사용하는 팩토리
  factory ThemeNormalized.fromDetailView(Map<String, dynamic> json) {
    return ThemeNormalized(
      id: json['id'] as int,
      code: json['code'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String,
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.now(), // 뷰에서는 간소화
      updatedAt: DateTime.now(),
      // moods는 array로 제공됨
      // tracks는 별도 조회 필요
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'icon_path': iconPath,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool containsMood(String moodName) {
    return moods.any((mood) => mood.name.toLowerCase().contains(moodName.toLowerCase()));
  }

  bool containsMoodById(int moodId) {
    return moods.any((mood) => mood.id == moodId);
  }

  int get trackCount => tracks.length;

  List<String> get moodNames => moods.map((m) => m.name).toList();

  @override
  String toString() => 'ThemeNormalized(id: $id, code: $code, title: $title, tracks: ${tracks.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeNormalized &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // 기존 Theme 모델과의 호환성을 위한 헬퍼
  ThemeNormalized copyWith({
    List<Mood>? moods,
    List<TrackNormalized>? tracks,
  }) {
    return ThemeNormalized(
      id: id,
      code: code,
      title: title,
      subtitle: subtitle,
      description: description,
      iconPath: iconPath,
      displayOrder: displayOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
      moods: moods ?? this.moods,
      tracks: tracks ?? this.tracks,
    );
  }
}