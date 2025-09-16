import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exam_history_entry.dart';

class HistoryStore {
  static const String _collectionName = 'examHistory';
  static const String _entriesField = 'entries';

  static DocumentReference<Map<String, dynamic>>? _docForCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection(_collectionName).doc(uid);
  }

  static Future<List<ExamHistoryEntry>> load() async {
    try {
      final doc = _docForCurrentUser();
      if (doc == null) return <ExamHistoryEntry>[];
      final snapshot = await doc.get();
      final data = snapshot.data();
      if (data == null) return <ExamHistoryEntry>[];
      final entries = data[_entriesField];
      if (entries == null) return <ExamHistoryEntry>[];
      return ExamHistoryEntry.decodeList(entries);
    } catch (_) {
      return <ExamHistoryEntry>[];
    }
  }

  static Future<void> add(ExamHistoryEntry entry) async {
    final doc = _docForCurrentUser();
    if (doc == null) return;
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(doc);
        final data = snapshot.data();
        final currentEntries = data == null
            ? <ExamHistoryEntry>[]
            : ExamHistoryEntry.decodeList(data[_entriesField]);
        currentEntries.insert(0, entry); // plus récent en premier
        transaction.set(doc, <String, dynamic>{
          _entriesField: ExamHistoryEntry.encodeList(currentEntries),
        });
      });
    } catch (_) {
      // Ignoré : l'ajout dans l'historique ne doit pas bloquer l'application.
    }
  }

  static Future<void> clear() async {
    final doc = _docForCurrentUser();
    if (doc == null) return;
    try {
      await doc.delete();
    } catch (_) {
      // Ignoré.
    }
  }
}
