class UserProfile {
  final String nickname;
  final String profession;

  const UserProfile({
    this.nickname = '',
    this.profession = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        nickname: (json['nickname'] ?? '') as String,
        profession: (json['profession'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'profession': profession,
      };
}
