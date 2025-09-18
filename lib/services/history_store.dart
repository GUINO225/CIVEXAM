import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exam_history_entry.dart';
import 'local_history_store.dart';

class HistoryStore {
  static const String _collectionName = 'examHistory';
  static const String _entriesField = 'entries';
  static const int _maxLocalItems = 100;

  static DocumentReference<Map<String, dynamic>>? _docForCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_collectionName)
        .doc('summary');
  }

  static Future<List<ExamHistoryEntry>> load() {
    return loadLocal();
  }

  static Future<List<ExamHistoryEntry>> loadLocal() async {
    final raw = await LocalHistoryStore.loadExam();
    final entries = <ExamHistoryEntry>[];
    for (final item in raw) {
      try {
        entries.add(ExamHistoryEntry.fromJson(item));
      } catch (_) {}
    }
    return entries;
  }

  static Future<void> add(ExamHistoryEntry entry,
      {bool syncToCloud = true}) async {
    final localEntries = await LocalHistoryStore.loadExam();
    localEntries.insert(0, _toLocalMap(entry));
    if (localEntries.length > _maxLocalItems) {
      localEntries.removeRange(_maxLocalItems, localEntries.length);
    }
    await LocalHistoryStore.saveExam(localEntries);

    if (!syncToCloud) {
      return;
    }

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
        if (currentEntries.length > _maxLocalItems) {
          currentEntries.removeRange(
              _maxLocalItems, currentEntries.length);
        }
        transaction.set(doc, <String, dynamic>{
          _entriesField: ExamHistoryEntry.encodeList(currentEntries),
        });
      });
    } catch (_) {
      // Ignoré : l'ajout dans l'historique ne doit pas bloquer l'application.
    }
  }

  static Future<void> clear() async {
    await LocalHistoryStore.clearExam();
    final doc = _docForCurrentUser();
    if (doc == null) return;
    try {
      await doc.delete();
    } catch (_) {
      // Ignoré.
    }
  }

  static Map<String, dynamic> _toLocalMap(ExamHistoryEntry entry) {
    return <String, dynamic>{
      'date': entry.date.toIso8601String(),
      'correctBySubject': entry.correctBySubject,
      'totalBySubject': entry.totalBySubject,
      'scoresBruts': entry.scoresBruts,
      'scoresPonderes': entry.scoresPonderes,
      'totalPondere': entry.totalPondere,
      'success': entry.success,
      'abandoned': entry.abandoned,
    };
  }
}
