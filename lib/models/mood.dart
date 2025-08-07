class Mood {
  final int id;
  final String name;
  final String? emoji;
  final String? color;
  final int displayOrder;
  final DateTime createdAt;

  Mood({
    required this.id,
    required this.name,
    this.emoji,
    this.color,
    required this.displayOrder,
    required this.createdAt,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'] as int,
      name: json['name'] as String,
      emoji: json['emoji'] as String?,
      color: json['color'] as String?,
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Mood(id: $id, name: $name, emoji: $emoji)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mood &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}