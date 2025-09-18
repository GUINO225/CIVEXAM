// lib/services/leaderboard_store.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/leaderboard_entry.dart';
import 'private_scores_store.dart';

class LeaderboardStore {
  static const _collectionName = 'leaderboards';
  static const int _maxEntries = 100;
  static const int _batchSize = 400;

  static final List<LeaderboardEntry> _memoryEntries = <LeaderboardEntry>[];

  static bool get _firebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static CollectionReference<Map<String, dynamic>>? _collection() {
    if (!_firebaseReady) return null;
    return FirebaseFirestore.instance.collection(_collectionName);
  }

  static Query<Map<String, dynamic>> _orderedQuery(
      CollectionReference<Map<String, dynamic>> col) {
    return col
        .orderBy('percent', descending: true)
        .orderBy('durationSec')
        .orderBy('dateIso', descending: true);
  }

  static List<LeaderboardEntry> _sortEntries(
      List<LeaderboardEntry> entries) {
    entries.sort((a, b) {
      final p = b.percent.compareTo(a.percent);
      if (p != 0) return p;
      final d = a.durationSec.compareTo(b.durationSec);
      if (d != 0) return d;
      return b.dateIso.compareTo(a.dateIso);
    });
    return entries.take(_maxEntries).toList(growable: false);
  }

  static Future<void> add(LeaderboardEntry e) async {
    if (e.mode == 'training') {
      await PrivateScoresStore.add(e);
      return;
    }
    final updated = List<LeaderboardEntry>.from(_memoryEntries)..add(e);
    final sorted = _sortEntries(updated);
    _memoryEntries
      ..clear()
      ..addAll(sorted);

    final col = _collection();
    if (col == null) return;
    try {
      await col.add({
        ...e.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _trimExcess(col);
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('LeaderboardStore.add failed: $err\n$st');
      }
    }
  }

  static Future<List<LeaderboardEntry>> all() async {
    final localEntries = await PrivateScoresStore.load();
    final col = _collection();
    if (col == null) {
      return [...localEntries, ..._memoryEntries];
    }
    try {
      final snapshot = await _orderedQuery(col).limit(_maxEntries).get();
      final entries = snapshot.docs
          .map((doc) => LeaderboardEntry.fromJson(doc.data()))
          .toList(growable: false);
      _memoryEntries
        ..clear()
        ..addAll(entries);
      return [...localEntries, ...entries];
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('LeaderboardStore.all failed: $err\n$st');
      }
      return [...localEntries, ..._memoryEntries];
    }
  }

  static Future<void> clear() async {
    _memoryEntries.clear();
    await PrivateScoresStore.clear();
    final col = _collection();
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
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('LeaderboardStore.clear failed: $err\n$st');
      }
    }
  }

  static Future<void> _trimExcess(
      CollectionReference<Map<String, dynamic>> col) async {
    try {
      final topSnapshot = await _orderedQuery(col).limit(_maxEntries).get();
      if (topSnapshot.docs.length < _maxEntries ||
          topSnapshot.docs.isEmpty) {
        return;
      }
      var lastKept = topSnapshot.docs.last;
      Query<Map<String, dynamic>> query = _orderedQuery(col)
          .startAfterDocument(lastKept)
          .limit(_batchSize);
      while (true) {
        final snapshot = await query.get();
        if (snapshot.docs.isEmpty) break;
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        if (snapshot.docs.length < _batchSize) break;
        lastKept = snapshot.docs.last;
        query = _orderedQuery(col)
            .startAfterDocument(lastKept)
            .limit(_batchSize);
      }
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('LeaderboardStore._trimExcess failed: $err\n$st');
      }
    }
  }
}
