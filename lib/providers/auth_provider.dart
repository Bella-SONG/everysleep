import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // Supabase 초기화 확인 후 인증 상태 변경 리스너 설정
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    try {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        final session = data.session;
        
        debugPrint('🔄 Auth State Change: $event');
        
        if (event == AuthChangeEvent.signedIn && session != null) {
          debugPrint('✅ 로그인 성공: ${session.user.id}');
          _user = session.user;
          notifyListeners();
        } else if (event == AuthChangeEvent.signedOut) {
          debugPrint('🔓 로그아웃됨');
          _user = null;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('⚠️ Auth listener 초기화 지연: $e');
    }
  }

  /// 초기 인증 상태 확인
  Future<void> checkAuth() async {
    debugPrint('🚀 AuthProvider 인증 상태 확인 시작');
    
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        debugPrint('✅ 기존 세션 발견');
        _user = session.user;
      } else {
        debugPrint('❌ 저장된 세션 없음');
      }
    } catch (error) {
      debugPrint('❌ 세션 확인 에러: $error');
    }
    
    debugPrint('✅ AuthProvider 인증 상태 확인 완료');
  }

  /// 카카오 로그인
  Future<bool> signInWithKakao() async {
    try {
      debugPrint('=== Supabase 카카오 OAuth 시작 ===');
      _setLoading(true);

      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: 'com.everysleep.everysleep://login',
      );
      
      // OAuth는 브라우저에서 처리되고 callback으로 돌아옴
      debugPrint('✅ 카카오 OAuth 브라우저 열림');
      _setLoading(false);
      return true;

    } catch (error) {
      debugPrint('❌ 카카오 OAuth 실패: $error');
      _setLoading(false);
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      debugPrint('🔓 로그아웃 시작');
      _setLoading(true);
      
      // Supabase 세션 완전 삭제
      await Supabase.instance.client.auth.signOut();
      
      // 로컬 상태 즉시 초기화
      _user = null;
      
      debugPrint('✅ 로그아웃 완료');
      _setLoading(false);
      notifyListeners();
    } catch (error) {
      debugPrint('❌ 로그아웃 실패: $error');
      
      // 오류가 발생해도 로컬 상태는 초기화
      _user = null;
      _setLoading(false);
      notifyListeners();
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 인증 상태 재확인
  Future<void> recheckAuthStatus() async {
    debugPrint('🔍 인증 상태 재확인');
    await checkAuth();
  }
}