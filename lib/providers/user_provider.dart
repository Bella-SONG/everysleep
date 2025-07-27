import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      _userProfile = UserProfile.fromJson(response);
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

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final data = {
        'user_id': userId,
        'nickname': nickname,
        'birth_date': birthDate.toIso8601String(),
        'gender': gender,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('user_profiles')
          .upsert(data);

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

  void clearUserProfile() {
    _userProfile = null;
    notifyListeners();
  }
}