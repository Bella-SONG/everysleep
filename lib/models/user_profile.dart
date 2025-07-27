class UserProfile {
  final String userId;
  final String nickname;
  final DateTime birthDate;
  final String gender;

  UserProfile({
    required this.userId,
    required this.nickname,
    required this.birthDate,
    required this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      gender: json['gender'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nickname': nickname,
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
    };
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}