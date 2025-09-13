import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

class UserProfileService {
  final _col = FirebaseFirestore.instance.collection('users');

  Future<UserProfile?> fetch(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  Future<void> save(UserProfile profile, {String? uid}) async {
    final userId = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    await _col.doc(userId).set(profile.toJson(), SetOptions(merge: true));
  }
}
