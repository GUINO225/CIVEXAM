// lib/services/competition_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
    final data = entry.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    try {
      await _col.doc(entry.userId).set(data);
    } catch (e) {
      throw Exception("Échec de l'enregistrement du score: $e");
    }
  }

  /// Récupère les meilleurs résultats (max 100 par défaut).
  Future<List<LeaderboardEntry>> topEntries({int limit = 100}) async {
    try {
      final snap = await _col
          .orderBy('percent', descending: true)
          .orderBy('durationSec')
          .limit(limit)
          .get();
      return snap.docs
          .map((d) => LeaderboardEntry.fromJson(d.data()))
          .toList();
    } catch (e, st) {
      debugPrint('topEntries failed: limit=$limit, error: $e');
      debugPrintStack(stackTrace: st);
      return [];
    }
  }

  /// Récupère le résultat d'un utilisateur spécifique.
  Future<LeaderboardEntry?> entryForUser(String userId) async {
    try {
      final doc = await _col.doc(userId).get();
      if (!doc.exists) return null;
      return LeaderboardEntry.fromJson(doc.data()!);
    } catch (e, st) {
      debugPrint('entryForUser failed: userId=$userId, error: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  /// Retourne un flux des meilleurs résultats (max 100 par défaut).
  Stream<List<LeaderboardEntry>> topEntriesStream({int limit = 100}) {
    return _col
        .orderBy('percent', descending: true)
        .orderBy('durationSec')
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => LeaderboardEntry.fromJson(d.data())).toList());
  }
}
