import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  kakao.User? _user;
  bool _isLoading = false;

  kakao.User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    debugPrint('=== AuthProvider 초기화 시작 ===');
    // SharedPreferences에서 저장된 로그인 정보 확인
    await _checkSavedLogin();
    debugPrint('=== AuthProvider 초기화 완료 ===');
  }

  Future<void> _checkSavedLogin() async {
    try {
      debugPrint('저장된 로그인 정보 확인 시작');
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('kakao_user_id');
      final savedNickname = prefs.getString('kakao_nickname');
      
      debugPrint('저장된 사용자 ID: $savedUserId');
      
      if (savedUserId != null && savedNickname != null) {
        // 카카오 토큰이 유효한지 확인
        try {
          debugPrint('카카오 토큰 유효성 확인 중...');
          await kakao.UserApi.instance.accessTokenInfo();
          // 토큰이 유효하면 카카오 사용자 정보 가져오기
          _user = await kakao.UserApi.instance.me();
          debugPrint('저장된 로그인 정보로 자동 로그인 완료');
        } catch (e) {
          debugPrint('토큰 만료됨, 저장된 정보 삭제: $e');
          await _clearSavedLogin();
        }
      } else {
        debugPrint('저장된 로그인 정보 없음');
      }
    } catch (e) {
      debugPrint('저장된 로그인 정보 확인 에러: $e');
    }
  }

  Future<void> _saveLoginInfo(kakao.User kakaoUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('kakao_user_id', kakaoUser.id.toString());
      await prefs.setString('kakao_nickname', kakaoUser.kakaoAccount?.profile?.nickname ?? '');
      await prefs.setString('kakao_profile_image', kakaoUser.kakaoAccount?.profile?.profileImageUrl ?? '');
    } catch (e) {
      debugPrint('로그인 정보 저장 에러: $e');
    }
  }

  Future<void> _clearSavedLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('kakao_user_id');
      await prefs.remove('kakao_nickname');
      await prefs.remove('kakao_profile_image');
    } catch (e) {
      debugPrint('저장된 로그인 정보 삭제 에러: $e');
    }
  }

  Future<bool> signInWithKakao() async {
    try {
      debugPrint('=== 카카오 로그인 프로세스 시작 ===');
      debugPrint('현재 인증 상태: $isAuthenticated');
      debugPrint('현재 사용자: ${_user?.id}');
      
      _isLoading = true;
      notifyListeners();
      debugPrint('로딩 상태 활성화됨');

      // 카카오 로그인 수행 (타임아웃 없음 - 사용자가 직접 취소할 때까지 대기)
      final result = await _performKakaoLogin();
      
      debugPrint('=== 카카오 로그인 프로세스 완료 ===');
      debugPrint('최종 결과: $result');
      debugPrint('최종 인증 상태: $isAuthenticated');
      debugPrint('최종 사용자: ${_user?.id}');
      
      return result;
    } catch (e) {
      debugPrint('❌ 카카오 로그인 최상위 에러: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _performKakaoLogin() async {
    try {
      debugPrint('--- 카카오 로그인 실행 단계 시작 ---');
      
      // 카카오톡 설치 여부 확인
      bool isInstalled = await kakao.isKakaoTalkInstalled();
      debugPrint('📱 카카오톡 설치 여부: $isInstalled');
      
      kakao.OAuthToken token;
      if (isInstalled) {
        // 카카오톡 앱으로 로그인
        try {
          debugPrint('🔄 카카오톡 앱으로 로그인 시도');
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
          debugPrint('✅ 카카오톡 앱 로그인 성공');
        } catch (e) {
          debugPrint('⚠️ 카카오톡 앱 로그인 실패, 계정 로그인으로 전환: $e');
          debugPrint('🔄 카카오 계정으로 로그인 재시도');
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
          debugPrint('✅ 카카오 계정 로그인 성공');
        }
      } else {
        debugPrint('🔄 카카오 계정으로 로그인 시도 (앱 미설치)');
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
        debugPrint('✅ 카카오 계정 로그인 성공');
      }

      debugPrint('🔑 토큰 획득 성공: ${token.accessToken.substring(0, 10)}...');
      debugPrint('🔑 리프레시 토큰 존재: ${token.refreshToken != null}');

      // 카카오 사용자 정보 가져오기
      debugPrint('👤 사용자 정보 요청 중...');
      kakao.User kakaoUser = await kakao.UserApi.instance.me();
      debugPrint('👤 사용자 정보 획득 성공');
      debugPrint('   - ID: ${kakaoUser.id}');
      debugPrint('   - 닉네임: ${kakaoUser.kakaoAccount?.profile?.nickname}');
      debugPrint('   - 이메일: ${kakaoUser.kakaoAccount?.email}');
      
      // 로그인 정보 저장
      debugPrint('💾 로그인 정보 저장 중...');
      await _saveLoginInfo(kakaoUser);
      debugPrint('💾 로그인 정보 저장 완료');
      
      // 사용자 정보 설정
      debugPrint('🔧 사용자 정보 설정 중...');
      _user = kakaoUser;
      debugPrint('🔧 사용자 정보 설정 완료: ${_user?.id}');
      debugPrint('🔧 인증 상태 확인: $isAuthenticated');
      
      _isLoading = false;
      debugPrint('⏳ 로딩 상태 비활성화');
      
      // UI 업데이트를 위해 확실히 notify
      debugPrint('🔄 첫 번째 notifyListeners 호출');
      notifyListeners();
      
      // 한 번 더 delay 후 notify (안전장치)
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('🔄 두 번째 notifyListeners 호출 (100ms 후)');
      notifyListeners();
      
      debugPrint('✅ _performKakaoLogin 성공 완료');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ _performKakaoLogin 에러 발생: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // 카카오 로그아웃
      try {
        await kakao.UserApi.instance.logout();
      } catch (e) {
        debugPrint('카카오 로그아웃 에러: $e');
      }
      
      // 저장된 로그인 정보 삭제
      await _clearSavedLogin();
      
      // 사용자 정보 초기화
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('로그아웃 에러: $e');
    }
  }
}