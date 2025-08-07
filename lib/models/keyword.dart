class Keyword {
  final int id;
  final String name;
  final String? category; // '효과', '장르', '분위기' 등
  final DateTime createdAt;

  Keyword({
    required this.id,
    required this.name,
    this.category,
    required this.createdAt,
  });

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Keyword(id: $id, name: $name, category: $category)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Keyword &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}