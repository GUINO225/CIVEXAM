class UserProfile {
  final String name;
  final String nickname;
  final String photoUrl;

  const UserProfile({
    required this.name,
    required this.nickname,
    required this.photoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: (json['name'] ?? '') as String,
        nickname: (json['nickname'] ?? '') as String,
        photoUrl: (json['photoUrl'] ?? '') as String,
      );
}
