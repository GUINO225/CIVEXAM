// lib/services/competition_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';

/// Service Firestore pour le mode Compétition.
///
/// Enregistre les résultats dans la collection `competition_scores`
/// et permet de récupérer un classement trié par pourcentage décroissant,
/// puis par durée croissante.
class CompetitionService {
  final CollectionReference<Map<String, dynamic>> _col;

  CompetitionService({CollectionReference<Map<String, dynamic>>? col})
      : _col = col ??
            FirebaseFirestore.instance.collection('competition_scores');

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
  ///
  /// En cas d'erreur (par exemple réseau), l'exception est relancée afin
  /// que l'appelant puisse l'intercepter et afficher un message adapté.
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
    } catch (e) {
      rethrow;
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
