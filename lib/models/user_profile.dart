// lib/models/user_profile.dart
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
  });
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
      };
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        uid: (json['uid'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        photoUrl: (json['photoUrl'] ?? '') as String,
      );
}
