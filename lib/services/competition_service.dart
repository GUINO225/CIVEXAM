// lib/services/competition_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/leaderboard_entry.dart';

/// Service Firestore pour le mode Compétition.
///
/// Enregistre les résultats dans la collection `competition_scores`
/// et permet de récupérer un classement trié par pourcentage décroissant,
/// puis par durée croissante.
class CompetitionService {
  final _col = FirebaseFirestore.instance.collection('competition_scores');

  /// Sauvegarde ou met à jour un résultat de compétition pour l'utilisateur.
  Future<void> saveEntry(LeaderboardEntry entry) async {
    const reconnectMessage =
        'Votre session a expiré, veuillez vous reconnecter pour enregistrer votre score.';
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception(reconnectMessage);
    }
    final uid = user.uid;
    if (entry.userId.isNotEmpty && entry.userId != uid) {
      debugPrint(
          'saveEntry aborted: mismatched userId (entry=${entry.userId}, uid=$uid)');
      throw Exception(reconnectMessage);
    }
    final data = entry.toJson();
    data['userId'] = uid;
    data['updatedAt'] = FieldValue.serverTimestamp();
    data['mode'] = 'competition';
    try {
      await _col.doc(uid).set(data);
    } catch (e) {
      throw Exception("Échec de l'enregistrement du score: $e");
    }
  }

  /// Récupère les meilleurs résultats (max 100 par défaut).
  Future<List<LeaderboardEntry>> topEntries({int limit = 100}) async {
    try {
      return await _fetchSortedEntries(
        baseQuery: _col.where('mode', isEqualTo: 'competition'),
        limit: limit,
      );
    } on FirebaseException catch (e, st) {
      if (e.code == 'failed-precondition') {
        debugPrint(
            'topEntries filtered query missing index, falling back. Error: $e');
        debugPrintStack(stackTrace: st);
        try {
          return await _fetchSortedEntries(baseQuery: _col, limit: limit);
        } catch (err, stack) {
          debugPrint('topEntries fallback failed: $err');
          debugPrintStack(stackTrace: stack);
          return [];
        }
      }
      debugPrint('topEntries firebase error: $e');
      debugPrintStack(stackTrace: st);
      return [];
    } catch (e, st) {
      debugPrint('topEntries failed: limit=$limit, error: $e');
      debugPrintStack(stackTrace: st);
      return [];
    }
  }

  /// Supprime les anciens enregistrements non liés au mode compétition.
  Future<void> purgeLegacyEntries() async {
    const legacyModes = <String>{'training', 'concours'};
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('purgeLegacyEntries skipped: no authenticated user');
      return;
    }

    try {
      final doc = await _col.doc(user.uid).get();
      if (!doc.exists) return;

      final data = doc.data();
      if (data == null) return;

      final mode = data['mode'] as String? ?? 'competition';
      if (!legacyModes.contains(mode)) return;

      await _col.doc(user.uid).delete();
    } on FirebaseException catch (e, st) {
      debugPrint('purgeLegacyEntries failed for user=${user.uid}: $e');
      debugPrintStack(stackTrace: st);
    } catch (e, st) {
      debugPrint('purgeLegacyEntries failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  /// Récupère le résultat d'un utilisateur spécifique.
  Future<LeaderboardEntry?> entryForUser(String userId) async {
    try {
      final doc = await _col.doc(userId).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      if ((data['mode'] ?? 'competition') != 'competition') {
        return null;
      }
      return LeaderboardEntry.fromJson(data);
    } catch (e, st) {
      debugPrint('entryForUser failed: userId=$userId, error: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  /// Retourne un flux des meilleurs résultats (max 100 par défaut).
  Stream<List<LeaderboardEntry>> topEntriesStream({int limit = 100}) {
    final query = _col
        .orderBy('percent', descending: true)
        .orderBy('durationSec')
        .limit(limit);
    return query.snapshots().map((snap) => snap.docs
        .map((d) => LeaderboardEntry.fromJson(d.data()))
        .where((entry) => entry.mode == 'competition')
        .toList());
  }

  Future<List<LeaderboardEntry>> _fetchSortedEntries({
    required Query<Map<String, dynamic>> baseQuery,
    required int limit,
  }) async {
    final snap = await baseQuery
        .orderBy('percent', descending: true)
        .orderBy('durationSec')
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => LeaderboardEntry.fromJson(d.data()))
        .where((entry) => entry.mode == 'competition')
        .toList();
  }
}
