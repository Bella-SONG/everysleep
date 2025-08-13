import 'package:flutter/material.dart';

class AppTheme {
  // 시니어 친화적 색상 팔레트
  static const Color primaryColor = Color(0xFF2D3748);        // 다크 그레이 (블랙에 가까운)
  static const Color secondaryColor = Color(0xFF4A5568);      // 미디엄 그레이
  static const Color accentColor = Color(0xFF50C878);         // 부드러운 그린
  static const Color backgroundColor = Color(0xFFFAFAFA);     // 뉴트럴 화이트
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Color(0xFFF0F4F8);          // 연한 카드 배경
  static const Color textPrimaryColor = Color(0xFF1A202C);    // 높은 대비 텍스트
  static const Color textSecondaryColor = Color(0xFF4A5568); // 중간 대비 텍스트
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);
  static const Color warningColor = Color(0xFFD69E2E);

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 16.0;
  static const double borderRadiusL = 24.0;

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  static ThemeData getLightTheme(double fontScale) {
    return ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textPrimaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(64), // 버튼 높이 증가
        padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: TextStyle(
          fontSize: 20 * fontScale, // 버튼 텍스트 크기 증가
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
        shadowColor: primaryColor.withValues(alpha: 0.3),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: TextStyle(
          fontSize: 16 * fontScale,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: TextStyle(
        fontSize: 16 * fontScale,
        color: textSecondaryColor,
      ),
      hintStyle: TextStyle(
        fontSize: 16 * fontScale,
        color: textSecondaryColor,
      ),
    ),
    textTheme: TextTheme(
      // 시니어 친화적으로 폰트 크기 증가 + 프리텐다드 적용
      headlineLarge: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 36 * fontScale,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 28 * fontScale,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 22 * fontScale,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 20 * fontScale,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 18 * fontScale,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 18 * fontScale,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 16 * fontScale,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
        height: 1.5,
      ),
    ),
  );
  }

  // 기본 테마 (호환성을 위해 유지)
  static ThemeData lightTheme = getLightTheme(1.0);
}