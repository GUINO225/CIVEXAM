// lib/models/user_profile.dart
class UserProfile {
  final String firstName, lastName, nickname, profession, photoUrl;
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.nickname,
    required this.profession,
    required this.photoUrl,
  });
  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'nickname': nickname,
        'profession': profession,
        'photoUrl': photoUrl,
      };
  factory UserProfile.fromJson(Map<String, dynamic> m) => UserProfile(
        firstName: (m['firstName'] ?? '') as String,
        lastName: (m['lastName'] ?? '') as String,
        nickname: (m['nickname'] ?? '') as String,
        profession: (m['profession'] ?? '') as String,
        photoUrl: (m['photoUrl'] ?? '') as String,
      );
}
