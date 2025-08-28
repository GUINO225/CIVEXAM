// lib/services/competition_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';

/// Service Firestore pour le mode Compétition.
///
/// Enregistre les résultats dans la collection `competition_scores`
/// et permet de récupérer un classement trié par pourcentage décroissant,
/// puis par durée croissante.
class CompetitionService {
  final _col = FirebaseFirestore.instance.collection('competition_scores');

  /// Sauvegarde un résultat de compétition.
  Future<void> saveEntry(LeaderboardEntry entry) async {
    final data = entry.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _col.add(data);
  }

  /// Récupère les meilleurs résultats (max 100 par défaut).
  Future<List<LeaderboardEntry>> topEntries({int limit = 100}) async {
    final snap = await _col
        .orderBy('percent', descending: true)
        .orderBy('durationSec')
        .limit(limit)
        .get();
    return snap.docs.map((d) => LeaderboardEntry.fromJson(d.data())).toList();
  }
}
