import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      // SharedPreferences에서 사용자 프로필 로드
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('kakao_user_id');
      final nickname = prefs.getString('user_nickname');
      final birthDateStr = prefs.getString('user_birth_date');
      final gender = prefs.getString('user_gender');

      if (userId != null && nickname != null && birthDateStr != null && gender != null) {
        _userProfile = UserProfile(
          userId: userId,
          nickname: nickname,
          birthDate: DateTime.parse(birthDateStr),
          gender: gender,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
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
      _isLoading = true;
      notifyListeners();

      // SharedPreferences에서 사용자 ID 가져오기
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('kakao_user_id');
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // SharedPreferences에 프로필 정보 저장
      await prefs.setString('user_nickname', nickname);
      await prefs.setString('user_birth_date', birthDate.toIso8601String());
      await prefs.setString('user_gender', gender);

      _userProfile = UserProfile(
        userId: userId,
        nickname: nickname,
        birthDate: birthDate,
        gender: gender,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
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