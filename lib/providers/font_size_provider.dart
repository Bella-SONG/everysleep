import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontSizeLevel {
  small,
  normal,
  large,
  extraLarge,
}

class FontSizeProvider extends ChangeNotifier {
  FontSizeLevel _currentLevel = FontSizeLevel.normal;
  static const String _fontSizeKey = 'font_size_level';

  FontSizeLevel get currentLevel => _currentLevel;

  // 폰트 크기 배율
  double get scaleFactor {
    switch (_currentLevel) {
      case FontSizeLevel.small:
        return 0.9;
      case FontSizeLevel.normal:
        return 1.0;
      case FontSizeLevel.large:
        return 1.2;
      case FontSizeLevel.extraLarge:
        return 1.4;
    }
  }

  String get currentLevelName {
    switch (_currentLevel) {
      case FontSizeLevel.small:
        return '작게';
      case FontSizeLevel.normal:
        return '보통';
      case FontSizeLevel.large:
        return '크게';
      case FontSizeLevel.extraLarge:
        return '매우 크게';
    }
  }

  FontSizeProvider() {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_fontSizeKey) ?? FontSizeLevel.normal.index;
    _currentLevel = FontSizeLevel.values[savedIndex];
    notifyListeners();
  }

  Future<void> setFontSize(FontSizeLevel level) async {
    _currentLevel = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontSizeKey, level.index);
    notifyListeners();
  }

  // TextStyle에 적용하는 헬퍼 메서드
  TextStyle? applyFontSize(TextStyle? style) {
    if (style == null) return null;
    return style.copyWith(
      fontSize: (style.fontSize ?? 14) * scaleFactor,
    );
  }
}