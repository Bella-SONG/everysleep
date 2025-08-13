import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class NatureSound {
  final int id;
  final String code;
  final String title;
  final String? description;
  final String url;
  final String? thumbnail;
  final String? fileName;
  final String? iconName;
  final String? colorCode;
  final int displayOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NatureSound({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.url,
    this.thumbnail,
    this.fileName,
    this.iconName,
    this.colorCode,
    this.displayOrder = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // UI에서 사용할 아이콘 반환
  IconData get icon {
    switch (iconName) {
      case 'raven':
        return Symbols.raven;
      case 'fire':
        return Icons.local_fire_department;
      case 'rain':
        return Icons.grain;
      case 'water_drop':
        return Icons.water_drop;
      case 'waves':
        return Icons.waves;
      case 'air':
        return Icons.air;
      default:
        return Icons.music_note;
    }
  }

  // UI에서 사용할 색상 반환
  Color get color {
    if (colorCode == null) return Colors.grey;
    try {
      return Color(int.parse(colorCode!.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  // 기존 코드와의 호환성을 위한 getter들
  String get name => title;
  String get idString => code;

  // 데이터베이스에서 생성
  factory NatureSound.fromJson(Map<String, dynamic> json) {
    return NatureSound(
      id: json['id'] as int,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
      fileName: json['file_name'] as String?,
      iconName: json['icon_name'] as String?,
      colorCode: json['color'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // 데이터베이스로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'url': url,
      'thumbnail': thumbnail,
      'file_name': fileName,
      'icon_name': iconName,
      'color': colorCode,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}