import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Supabase 현재 세션에서 사용자 ID 가져오기
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ 로그인된 사용자가 없어서 프로필을 로드할 수 없습니다.');
        _isLoading = false;
        notifyListeners();
        return;
      }

      // SharedPreferences에서 사용자 프로필 로드
      final prefs = await SharedPreferences.getInstance();
      final nickname = prefs.getString('user_nickname');
      final birthDateStr = prefs.getString('user_birth_date');
      final gender = prefs.getString('user_gender');

      if (nickname != null && birthDateStr != null && gender != null) {
        _userProfile = UserProfile(
          userId: user.id,
          nickname: nickname,
          birthDate: DateTime.parse(birthDateStr),
          gender: gender,
        );
        debugPrint('✅ 사용자 프로필 로드 성공: $nickname');
      } else {
        debugPrint('📝 저장된 프로필 정보가 없습니다.');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 사용자 프로필 로드 오류: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile({
    required String nickname,
    required DateTime birthDate,
    required String gender,
  }) async {
    try {
      debugPrint('👤 프로필 업데이트 시작: nickname=$nickname, birthDate=$birthDate, gender=$gender');
      _isLoading = true;
      notifyListeners();

      // Supabase 현재 세션에서 사용자 ID 가져오기
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ 로그인된 사용자가 없습니다.');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final userId = user.id;
      debugPrint('👤 현재 로그인된 사용자 ID: $userId');

      // SharedPreferences에 프로필 정보 저장
      debugPrint('💾 SharedPreferences에 프로필 정보 저장 시작');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nickname', nickname);
      await prefs.setString('user_birth_date', birthDate.toIso8601String());
      await prefs.setString('user_gender', gender);
      await prefs.setString('kakao_user_id', userId); // 일관성을 위해 추가
      debugPrint('💾 SharedPreferences 저장 완료');

      _userProfile = UserProfile(
        userId: userId,
        nickname: nickname,
        birthDate: birthDate,
        gender: gender,
      );

      debugPrint('✅ 프로필 업데이트 성공');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ 프로필 업데이트 오류: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> clearUserProfile() async {
    try {
      // SharedPreferences에서 사용자 데이터 완전 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('kakao_user_id');
      await prefs.remove('user_nickname');
      await prefs.remove('user_birth_date');
      await prefs.remove('user_gender');
      
      debugPrint('🗑️ 사용자 프로필 데이터 완전 삭제');
      
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 사용자 프로필 삭제 실패: $e');
      // 오류가 발생해도 메모리에서는 삭제
      _userProfile = null;
      notifyListeners();
    }
  }
}