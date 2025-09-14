// lib/services/user_profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

/// Service Firestore pour le profil utilisateur.
class UserProfileService {
  final _col = FirebaseFirestore.instance.collection('users');

  /// Charge le profil de l'utilisateur [uid].
  Future<UserProfile?> loadProfile(String uid) async {
    try {
      final doc = await _col.doc(uid).get();
      final data = doc.data();
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e, st) {
      debugPrint('Error loading profile for $uid: $e\n$st');
      rethrow;
    }
  }

  /// Sauvegarde le profil de l'utilisateur actuellement connecté.
  Future<void> saveProfile(UserProfile profile) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('Aucun utilisateur authentifié');
    }
    try {
      await _col.doc(uid).set(profile.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception("Échec de l'enregistrement du profil: $e");
    }
  }
}
