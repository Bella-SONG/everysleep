import 'keyword.dart';

class TrackNormalized {
  final int id;
  final String code; // 기존 'S001' 같은 코드
  final String title;
  final String artist;
  final String url;
  final String? thumbnail;
  final String? category;
  final int? durationSeconds;
  final int? bpm;
  final String? fileName;
  final String? description;
  final bool isAsmr;
  final int displayOrder;
  final DateTime createdAt;

  // 관계 데이터 (JOIN 결과)
  final List<Keyword> keywords;

  TrackNormalized({
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
    this.isAsmr = false,
    required this.displayOrder,
    required this.createdAt,
    this.keywords = const [],
  });

  factory TrackNormalized.fromJson(Map<String, dynamic> json) {
    return TrackNormalized(
      id: json['id'] as int,
      code: json['code'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
      category: json['category'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      bpm: json['bpm'] as int?,
      fileName: json['file_name'] as String?,
      description: json['description'] as String?,
      isAsmr: json['is_asmr'] as bool? ?? false,
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      // keywords는 별도로 로드
    );
  }

  // track_details 뷰에서 사용하는 팩토리
  factory TrackNormalized.fromDetailView(Map<String, dynamic> json) {
    return TrackNormalized(
      id: json['id'] as int,
      code: json['code'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      description: json['description'] as String?,
      displayOrder: 0, // 뷰에서는 간소화
      createdAt: DateTime.now(),
      // keywords는 array로 제공됨 (처리 필요)
    );
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
    return keywords.any((k) => 
        k.name.toLowerCase().contains(keyword.toLowerCase()));
  }

  bool hasKeywordById(int keywordId) {
    return keywords.any((k) => k.id == keywordId);
  }

  List<String> get keywordNames => keywords.map((k) => k.name).toList();

  List<Keyword> get sleepKeywords => keywords
      .where((k) => k.name.contains('수면') || k.name.contains('이완'))
      .toList();

  List<Keyword> get energyKeywords => keywords
      .where((k) => k.name.contains('활력') || k.name.contains('기분전환'))
      .toList();

  @override
  String toString() => 'TrackNormalized(id: $id, code: $code, title: $title, duration: $formattedDuration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackNormalized &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // copyWith for updating relationships
  TrackNormalized copyWith({
    List<Keyword>? keywords,
  }) {
    return TrackNormalized(
      id: id,
      code: code,
      title: title,
      artist: artist,
      url: url,
      thumbnail: thumbnail,
      category: category,
      durationSeconds: durationSeconds,
      bpm: bpm,
      fileName: fileName,
      description: description,
      isAsmr: isAsmr,
      displayOrder: displayOrder,
      createdAt: createdAt,
      keywords: keywords ?? this.keywords,
    );
  }
}