import 'package:flutter/foundation.dart';

/// 앱 환경 설정
enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static Environment _environment = Environment.development;
  
  /// 현재 환경 설정
  static Environment get environment => _environment;
  
  /// 환경 설정 초기화
  static void initialize(Environment env) {
    _environment = env;
    if (kDebugMode) {
      print('🔧 App environment initialized: ${env.name}');
    }
  }
  
  /// 개발 환경 여부
  static bool get isDevelopment => _environment == Environment.development;
  
  /// 스테이징 환경 여부  
  static bool get isStaging => _environment == Environment.staging;
  
  /// 프로덕션 환경 여부
  static bool get isProduction => _environment == Environment.production;
  
  /// 로컬 데이터 사용 여부 (프로덕션에서는 항상 false)
  static bool get useLocalData => isProduction ? false : (isDevelopment && kDebugMode);
  
  /// 데이터베이스 연결 사용 여부
  static bool get useDatabaseConnection => !useLocalData;
  
  /// API 기본 URL
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://jxfeszksnsyelaqcfapv.supabase.co';
      case Environment.staging:
        return 'https://jxfeszksnsyelaqcfapv.supabase.co'; // staging URL이 있다면 변경
      case Environment.production:
        return 'https://jxfeszksnsyelaqcfapv.supabase.co';
    }
  }
  
  /// 로그 레벨 설정
  static bool get enableDetailedLogging => isDevelopment || isStaging;
  
  /// 에러 리포팅 활성화 여부
  static bool get enableErrorReporting => isProduction;
  
  /// 캐시 만료 시간 (분)
  static int get cacheExpirationMinutes {
    switch (_environment) {
      case Environment.development:
        return 5; // 개발시에는 짧게
      case Environment.staging:
        return 30;
      case Environment.production:
        return 60; // 프로덕션에서는 길게
    }
  }
  
  /// 재시도 횟수
  static int get maxRetryAttempts {
    switch (_environment) {
      case Environment.development:
        return 2;
      case Environment.staging:
        return 3;
      case Environment.production:
        return 3;
    }
  }
  
  /// 타임아웃 시간 (초)
  static int get requestTimeoutSeconds {
    switch (_environment) {
      case Environment.development:
        return 10;
      case Environment.staging:
        return 15;
      case Environment.production:
        return 15;
    }
  }
}