// lib/models/user_profile.dart
class UserProfile {
  static const String defaultArcadeLevel = 'Niveau 1';
  final String firstName,
      lastName,
      nickname,
      profession,
      photoUrl,
      arcadeLevel;
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.nickname,
    required this.profession,
    required this.photoUrl,
    this.arcadeLevel = defaultArcadeLevel,
  });
  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'nickname': nickname,
        'profession': profession,
        'photoUrl': photoUrl,
        'arcadeLevel': arcadeLevel,
        'badge': arcadeLevel,
      };
  factory UserProfile.fromJson(Map<String, dynamic> m) => UserProfile(
        firstName: (m['firstName'] ?? '') as String,
        lastName: (m['lastName'] ?? '') as String,
        nickname: (m['nickname'] ?? '') as String,
        profession: (m['profession'] ?? '') as String,
        photoUrl: (m['photoUrl'] ?? '') as String,
        arcadeLevel: _readLevel(m),
      );

  static String _readLevel(Map<String, dynamic> m) {
    final value = m['arcadeLevel'] ?? m['badge'] ?? '';
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? defaultArcadeLevel : trimmed;
    }
    if (value == null) return defaultArcadeLevel;
    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? defaultArcadeLevel : stringValue;
  }
}
