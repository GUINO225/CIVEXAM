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

  /// Retourne le nombre total de profils utilisateur disponibles.
  ///
  /// Utilise la requête d'agrégation Firestore, puis revient à une
  /// récupération minimale des documents si l'agrégation n'est pas
  /// disponible (ex. émulateur ou environnement restreint).
  Future<int?> countUsers() async {
    try {
      final aggregate = await _col.count().get();
      return aggregate.count;
    } catch (e, st) {
      debugPrint('Error counting users: $e\n$st');
      try {
        // Repli : on récupère uniquement les métadonnées des documents
        // pour limiter le volume transféré.
        final snapshot = await _col.get(
          const GetOptions(source: Source.server),
        );
        return snapshot.size;
      } catch (fallbackError, fallbackSt) {
        debugPrint('Fallback user count failed: $fallbackError\n$fallbackSt');
        return null;
      }
    }
  }
}
