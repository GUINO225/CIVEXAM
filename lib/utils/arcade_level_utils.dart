import '../models/user_profile.dart';

String normalizeArcadeLevel(String? value) {
  final trimmed = value?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }
  return UserProfile.defaultArcadeLevel;
}
