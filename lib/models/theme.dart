class Theme {
  final int id; // 정규화된 스키마: int형 SERIAL PK
  final String code; // 정규화된 스키마: 고유 코드 (theme_01, theme_02 등)
  final String title;
  final String subtitle;
  final String description;
  final List<String> trackIds; // 호환성 유지를 위해 유지
  final List<String> moods; // 호환성 유지를 위해 유지
  final String? iconPath;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? _trackCount; // 별도로 관리되는 트랙 개수

  Theme({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.trackIds,
    required this.moods,
    this.iconPath,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
    int? trackCount,
  }) : _trackCount = trackCount;

  factory Theme.fromJson(Map<String, dynamic> json) {
    return Theme(
      id: json['id'] as int, // 정규화된 스키마: int형
      code: json['code'] as String? ?? 'theme_${json['id']}', // 코드 필드 추가
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String,
      trackIds: _parseTrackIds(json), // 정규화된 데이터 파싱
      moods: _parseMoods(json), // 정규화된 데이터 파싱
      iconPath: json['icon_path'] as String?,
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? json['created_at'] as String),
      trackCount: json['track_count'] as int?, // 별도로 계산된 트랙 개수
    );
  }

  // 정규화된 데이터에서 트랙 ID들을 파싱하는 헬퍼 함수
  static List<String> _parseTrackIds(Map<String, dynamic> json) {
    // 기존 방식 (Array 타입)
    if (json['track_ids'] != null) {
      return List<String>.from(json['track_ids']);
    }
    
    // 정규화된 방식 (관계 테이블에서 조인된 데이터)
    // Supabase에서 theme_tracks -> tracks 조인 형태로 가져온 경우
    if (json['tracks'] != null && json['tracks'] is List) {
      final tracksList = json['tracks'] as List;
      List<String> trackCodes = [];
      
      for (var trackRelation in tracksList) {
        if (trackRelation is Map<String, dynamic> && trackRelation['tracks'] != null) {
          final track = trackRelation['tracks'] as Map<String, dynamic>;
          if (track['code'] != null) {
            trackCodes.add(track['code'] as String);
          }
        }
      }
      
      return trackCodes;
    }
    
    return [];
  }

  // 정규화된 데이터에서 기분들을 파싱하는 헬퍼 함수
  static List<String> _parseMoods(Map<String, dynamic> json) {
    // 기존 방식 (Array 타입)
    if (json['moods'] != null && json['moods'] is List) {
      return List<String>.from(json['moods']);
    }
    
    // 정규화된 방식 (관계 테이블에서 조인된 데이터)
    if (json['mood_list'] != null && json['mood_list'] is List) {
      return (json['mood_list'] as List).map((mood) => mood['name'] as String).toList();
    }
    
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'track_ids': trackIds, // 호환성 유지
      'moods': moods, // 호환성 유지
      'icon_path': iconPath,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool containsMood(String mood) {
    return moods.any((m) => m.toLowerCase().contains(mood.toLowerCase()));
  }

  int get trackCount => _trackCount ?? trackIds.length;

  @override
  String toString() => 'Theme(id: $id, code: $code, title: $title, tracks: ${trackIds.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Theme &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}