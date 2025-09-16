import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Persists IDs of questions already used so we can avoid repetitions
/// across quiz sessions.
class QuestionHistoryStore {
  static const String _collectionName = 'questionHistory';
  static const int _batchSize = 400; // Below Firestore's 500 writes per batch.

  static final Set<String> _memoryCache = <String>{};

  static bool get _firebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static CollectionReference<Map<String, dynamic>>? _historyCollection() {
    if (!_firebaseReady) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_collectionName);
  }

  /// Loads the set of question IDs already used.
  static Future<Set<String>> load() async {
    final col = _historyCollection();
    if (col == null) {
      return Set<String>.from(_memoryCache);
    }
    try {
      final snapshot = await col.get();
      final ids = snapshot.docs.map((doc) => doc.id).toSet();
      _memoryCache
        ..clear()
        ..addAll(ids);
      return ids;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('QuestionHistoryStore.load failed: $e\n$st');
      }
      return Set<String>.from(_memoryCache);
    }
  }

  /// Adds a single question ID to the history store.
  static Future<void> add(String id) async {
    _memoryCache.add(id);
    final col = _historyCollection();
    if (col == null) return;
    try {
      await col.doc(id).set({
        'used': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('QuestionHistoryStore.add failed: $e\n$st');
      }
    }
  }

  /// Adds multiple question IDs to the history store.
  static Future<void> addAll(Iterable<String> ids) async {
    final uniqueIds = ids.toSet();
    if (uniqueIds.isEmpty) return;
    _memoryCache.addAll(uniqueIds);
    final col = _historyCollection();
    if (col == null) return;
    try {
      final firestore = FirebaseFirestore.instance;
      final chunks = <List<String>>[];
      var chunk = <String>[];
      for (final id in uniqueIds) {
        chunk.add(id);
        if (chunk.length >= _batchSize) {
          chunks.add(chunk);
          chunk = <String>[];
        }
      }
      if (chunk.isNotEmpty) chunks.add(chunk);

      for (final part in chunks) {
        final batch = firestore.batch();
        for (final id in part) {
          batch.set(col.doc(id), {
            'used': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        await batch.commit();
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('QuestionHistoryStore.addAll failed: $e\n$st');
      }
      rethrow;
    }
  }

  /// Clears the stored question IDs.
  static Future<void> clear() async {
    _memoryCache.clear();
    final col = _historyCollection();
    if (col == null) return;
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      do {
        snapshot = await col.limit(_batchSize).get();
        if (snapshot.docs.isEmpty) break;
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } while (snapshot.docs.length >= _batchSize);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('QuestionHistoryStore.clear failed: $e\n$st');
      }
    }
  }
}
