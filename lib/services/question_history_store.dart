import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists IDs of questions already used so we can avoid repetitions
/// across quiz sessions.
class QuestionHistoryStore {
  static const String _collectionName = 'questionHistory';
  static const int _batchSize = 400; // Below Firestore's 500 writes per batch.

  static const String _prefsCacheKey = 'question_history_cache';
  static const String _prefsPendingKey = 'question_history_pending';
  static const String _prefsNeedsClearKey = 'question_history_needs_clear';

  static final Set<String> _memoryCache = <String>{};
  static final Set<String> _pendingSync = <String>{};

  static bool _localLoaded = false;
  static bool _needsRemoteClear = false;
  static Future<void>? _localLoadFuture;
  static Future<void>? _ongoingSync;

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
    await _ensureLocalLoaded();
    _scheduleRemoteSync();

    if (_needsRemoteClear) {
      return Set<String>.from(_memoryCache);
    }

    final col = _historyCollection();
    if (col == null) {
      return Set<String>.from(_memoryCache);
    }

    try {
      final snapshot = await col.get();
      final remoteIds = snapshot.docs.map((doc) => doc.id).toSet();

      var pendingChanged = false;
      for (final id in remoteIds) {
        if (_pendingSync.remove(id)) {
          pendingChanged = true;
        }
      }

      final combined = <String>{...remoteIds, ..._pendingSync};
      final cacheChanged = !setEquals(_memoryCache, combined);
      if (cacheChanged) {
        _memoryCache
          ..clear()
          ..addAll(combined);
      }

      if (cacheChanged || pendingChanged) {
        await _persistToLocalStore();
      }

      _scheduleRemoteSync();
      return Set<String>.from(_memoryCache);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('QuestionHistoryStore.load failed: $e\n$st');
      }
      return Set<String>.from(_memoryCache);
    }
  }

  /// Adds a single question ID to the history store.
  static Future<void> add(String id) async {
    await _ensureLocalLoaded();
    final changed = _memoryCache.add(id);
    final addedToPending = _pendingSync.add(id);
    if (changed || addedToPending) {
      await _persistToLocalStore();
    }
    _scheduleRemoteSync();
  }

  /// Adds multiple question IDs to the history store.
  static Future<void> addAll(Iterable<String> ids) async {
    final uniqueIds = ids.toSet();
    if (uniqueIds.isEmpty) return;
    await _ensureLocalLoaded();
    final beforeLength = _memoryCache.length;
    _memoryCache.addAll(uniqueIds);
    var pendingChanged = false;
    for (final id in uniqueIds) {
      pendingChanged = _pendingSync.add(id) || pendingChanged;
    }
    if (_memoryCache.length != beforeLength || pendingChanged) {
      await _persistToLocalStore();
    }
    _scheduleRemoteSync();
  }

  /// Clears the stored question IDs.
  static Future<void> clear() async {
    await _ensureLocalLoaded();
    final hadData = _memoryCache.isNotEmpty || _pendingSync.isNotEmpty || _needsRemoteClear;
    _memoryCache.clear();
    _pendingSync.clear();
    _needsRemoteClear = true;
    if (hadData) {
      await _persistToLocalStore();
    }
    _scheduleRemoteSync();
  }

  static Future<void> _ensureLocalLoaded() {
    if (_localLoaded) return Future.value();
    return _localLoadFuture ??= _loadFromLocalStore();
  }

  static Future<void> _loadFromLocalStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getStringList(_prefsCacheKey) ?? const <String>[];
      final pending = prefs.getStringList(_prefsPendingKey) ?? const <String>[];
      _needsRemoteClear = prefs.getBool(_prefsNeedsClearKey) ?? false;

      _memoryCache
        ..clear()
        ..addAll(cached);
      _pendingSync
        ..clear()
        ..addAll(pending);
      _localLoaded = true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('QuestionHistoryStore._loadFromLocalStore failed: $e\n$st');
      }
    } finally {
      _localLoadFuture = null;
    }
  }

  static Future<void> _persistToLocalStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheList = _memoryCache.toList()..sort();
      final pendingList = _pendingSync.toList()..sort();
      await prefs.setStringList(_prefsCacheKey, cacheList);
      await prefs.setStringList(_prefsPendingKey, pendingList);
      await prefs.setBool(_prefsNeedsClearKey, _needsRemoteClear);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('QuestionHistoryStore._persistToLocalStore failed: $e\n$st');
      }
    }
  }

  static void _scheduleRemoteSync() {
    if ((_pendingSync.isEmpty && !_needsRemoteClear) || _ongoingSync != null) {
      return;
    }
    if (_historyCollection() == null) {
      return;
    }
    _ongoingSync = _flushPendingToFirestore();
    unawaited(_ongoingSync!.whenComplete(() {
      _ongoingSync = null;
      if (_pendingSync.isNotEmpty || _needsRemoteClear) {
        _scheduleRemoteSync();
      }
    }));
  }

  static Future<void> _flushPendingToFirestore() async {
    try {
      while (true) {
        if (_needsRemoteClear) {
          final col = _historyCollection();
          if (col == null) {
            return;
          }
          final cleared = await _performRemoteClear(col);
          if (!cleared) {
            return;
          }
          _needsRemoteClear = false;
          await _persistToLocalStore();
          continue;
        }

        if (_pendingSync.isEmpty) {
          break;
        }

        final col = _historyCollection();
        if (col == null) {
          return;
        }

        final ids = _pendingSync.toList()..sort();
        final firestore = FirebaseFirestore.instance;
        for (var start = 0; start < ids.length; start += _batchSize) {
          final end = start + _batchSize < ids.length ? start + _batchSize : ids.length;
          final chunk = ids.sublist(start, end);
          final batch = firestore.batch();
          for (final id in chunk) {
            batch.set(col.doc(id), {
              'used': true,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
          await batch.commit();
        }

        var removed = false;
        for (final id in ids) {
          removed = _pendingSync.remove(id) || removed;
        }
        if (removed) {
          await _persistToLocalStore();
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('QuestionHistoryStore._flushPendingToFirestore failed: $e\n$st');
      }
      rethrow;
    }
  }

  static Future<bool> _performRemoteClear(
    CollectionReference<Map<String, dynamic>> col,
  ) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      do {
        snapshot = await col.limit(_batchSize).get();
        if (snapshot.docs.isEmpty) {
          break;
        }
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } while (snapshot.docs.length >= _batchSize);
      return true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('QuestionHistoryStore._performRemoteClear failed: $e\n$st');
      }
      return false;
    }
  }
}
