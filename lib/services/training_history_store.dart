import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/training_history_entry.dart';

class TrainingHistoryStore {
  static const String _collectionName = 'trainingHistory';
  static const String _entriesCollectionName = 'entries';
  static const int _maxItems = 100; // conservation des 100 dernières tentatives

  static Future<List<TrainingHistoryEntry>> load() async {
    final userDocument = _userDocument();
    if (userDocument == null) {
      return <TrainingHistoryEntry>[];
    }

    final entriesCollection =
        userDocument.collection(_entriesCollectionName);
    final snapshot = await entriesCollection
        .orderBy('date', descending: true)
        .limit(_maxItems)
        .get();

    return snapshot.docs
        .map(
          (doc) => TrainingHistoryEntry.fromJson(
            _normalizeEntry(doc.data()),
          ),
        )
        .toList();
  }

  static Future<void> add(TrainingHistoryEntry entry) async {
    final userDocument = _userDocument();
    if (userDocument == null) {
      return;
    }

    final entriesCollection = userDocument.collection(_entriesCollectionName);

    await userDocument.set(
      {
        'uid': userDocument.id,
        'lastEntryDate': entry.date.toIso8601String(),
      },
      SetOptions(merge: true),
    );

    await entriesCollection.doc().set(entry.toJson());

    final snapshot = await entriesCollection
        .orderBy('date', descending: true)
        .get();

    if (snapshot.size > _maxItems) {
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs.sublist(_maxItems)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  static Future<void> clear() async {
    final userDocument = _userDocument();
    if (userDocument == null) {
      return;
    }

    final entriesCollection = userDocument.collection(_entriesCollectionName);
    final snapshot = await entriesCollection.get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  static DocumentReference<Map<String, dynamic>>? _userDocument() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return FirebaseFirestore.instance.collection(_collectionName).doc(uid);
  }

  static Map<String, dynamic> _normalizeEntry(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);
    final date = normalized['date'];
    if (date is Timestamp) {
      normalized['date'] = date.toDate().toIso8601String();
    }
    return normalized;
  }
}
