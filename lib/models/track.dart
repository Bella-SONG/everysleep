class Track {
  final int id; // 정규화된 스키마: int형 SERIAL PK
  final String code; // 정규화된 스키마: 고유 코드 (S001, S002 등)
  final String title;
  final String artist;
  final String url;
  final String? thumbnail;
  final String? category;
  final int? durationSeconds;
  final int? bpm;
  final String? fileName;
  final String? description;
  final List<String> effectKeywords; // 호환성 유지를 위해 유지
  final bool isAsmr;
  final int displayOrder;
  final DateTime createdAt;

  Track({
    required this.id,
    required this.code,
    required this.title,
    required this.artist,
    required this.url,
    this.thumbnail,
    this.category,
    this.durationSeconds,
    this.bpm,
    this.fileName,
    this.description,
    this.effectKeywords = const [],
    this.isAsmr = false,
    required this.displayOrder,
    required this.createdAt,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as int, // 정규화된 스키마: int형
      code: json['code'] as String? ?? 'S${json['id']}', // 코드 필드 추가
      title: json['title'] as String,
      artist: json['artist'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
      category: json['category'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      bpm: json['bpm'] as int?,
      fileName: json['file_name'] as String?,
      description: json['description'] as String?,
      effectKeywords: _parseKeywords(json), // 정규화된 데이터 파싱
      isAsmr: json['is_asmr'] as bool? ?? false,
      displayOrder: json['display_order'] as int,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  // 정규화된 데이터에서 키워드들을 파싱하는 헬퍼 함수
  static List<String> _parseKeywords(Map<String, dynamic> json) {
    // 기존 방식 (Array 타입)
    if (json['effect_keywords'] != null) {
      return (json['effect_keywords'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    }
    
    // track_details 뷰의 JSONB 형태 ([{"name": "수면"}, {"name": "이완"}])
    if (json['keywords'] != null && json['keywords'] is List) {
      final keywordsList = json['keywords'] as List<dynamic>;
      
      // JSONB 객체 배열인 경우
      if (keywordsList.isNotEmpty && keywordsList.first is Map) {
        return keywordsList
            .map((item) => (item as Map<String, dynamic>)['name'] as String)
            .toList();
      }
      
      // 단순 문자열 배열인 경우
      return keywordsList.map((keyword) => keyword.toString()).toList();
    }
    
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'artist': artist,
      'url': url,
      'thumbnail': thumbnail,
      'category': category,
      'duration_seconds': durationSeconds,
      'bpm': bpm,
      'file_name': fileName,
      'description': description,
      'effect_keywords': effectKeywords, // 호환성 유지
      'is_asmr': isAsmr,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Duration helpers
  Duration get duration => Duration(seconds: durationSeconds ?? 0);
  
  String get formattedDuration {
    if (durationSeconds == null) return '--:--';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Keyword helpers
  bool hasKeyword(String keyword) {
    return effectKeywords.any((k) => 
        k.toLowerCase().contains(keyword.toLowerCase()));
  }

  List<String> get sleepKeywords => effectKeywords
      .where((k) => k.contains('수면') || k.contains('이완'))
      .toList();

  List<String> get energyKeywords => effectKeywords
      .where((k) => k.contains('활력') || k.contains('기분전환'))
      .toList();

  @override
  String toString() => 'Track(id: $id, code: $code, title: $title, duration: $formattedDuration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}