import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class ProfileService {
  final _col = FirebaseFirestore.instance.collection('users');

  Future<UserProfile?> fetchCurrentProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _col.doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data() ?? {});
      }
    } catch (_) {}
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return UserProfile(
      name: user.displayName ?? '',
      nickname: user.displayName ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }
}
