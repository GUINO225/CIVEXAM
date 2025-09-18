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

  static const String _prefsCacheKeyBase = 'question_history_cache';
  static const String _prefsPendingKeyBase = 'question_history_pending';
  static const String _prefsNeedsClearKeyBase = 'question_history_needs_clear';
  static const String _defaultUserKey = 'local';

  static final Set<String> _memoryCache = <String>{};
  static final Set<String> _pendingSync = <String>{};

  static bool _localLoaded = false;
  static bool _needsRemoteClear = false;
  static Future<void>? _localLoadFuture;
  static Future<void>? _ongoingSync;

  static bool _remoteSyncEnabled = false;
  static bool _userKeyInitialized = false;
  static String _activeUserKey = _defaultUserKey;
  static StreamSubscription<User?>? _authSubscription;

  static bool get _firebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Enables or disables the optional Firestore synchronization.
  static void setRemoteSyncEnabled(bool enabled) {
    if (_remoteSyncEnabled == enabled) {
      return;
    }
    _remoteSyncEnabled = enabled;
    if (_remoteSyncEnabled) {
      _setupAuthListener();
      _updateActiveUserKey();
      _scheduleRemoteSync();
    }
  }

  static void _setupAuthListener() {
    if (_authSubscription != null || !_firebaseReady) {
      return;
    }
    try {
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
        (user) {
          _switchActiveUser(_userKeyFromUid(user?.uid));
        },
        onError: (Object error, StackTrace st) {
          if (kDebugMode) {
            debugPrint(
              'QuestionHistoryStore._setupAuthListener error: $error\n$st',
            );
          }
        },
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('QuestionHistoryStore._setupAuthListener failed: $e\n$st');
      }
    }
  }

  static void _updateActiveUserKey() {
    final resolved = _resolveCurrentUserKey();
    _switchActiveUser(resolved);
  }

  static void _switchActiveUser(String newKey) {
    if (_userKeyInitialized && newKey == _activeUserKey) {
      return;
    }
    _userKeyInitialized = true;
    _activeUserKey = newKey;
    _memoryCache.clear();
    _pendingSync.clear();
    _needsRemoteClear = false;
    _localLoaded = false;
    _localLoadFuture = null;
  }

  static String _resolveCurrentUserKey() {
    if (!_firebaseReady) {
      return _defaultUserKey;
    }
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      return _userKeyFromUid(uid);
    } catch (_) {
      return _defaultUserKey;
    }
  }

  static String _userKeyFromUid(String? uid) {
    if (uid == null || uid.isEmpty) {
      return _defaultUserKey;
    }
    return uid;
  }

  static String _scopedPrefsKey(String base, String userKey) {
    return '${base}_$userKey';
  }

  static Future<void> _migrateLegacyKeysIfNeeded(
    SharedPreferences prefs,
    String userKey,
  ) async {
    const legacyKeys = <String>{
      _prefsCacheKeyBase,
      _prefsPendingKeyBase,
      _prefsNeedsClearKeyBase,
    };
    final hasLegacy = legacyKeys.any(prefs.containsKey);
    if (!hasLegacy) {
      return;
    }

    final cacheKey = _scopedPrefsKey(_prefsCacheKeyBase, userKey);
    final pendingKey = _scopedPrefsKey(_prefsPendingKeyBase, userKey);
    final needsClearKey = _scopedPrefsKey(_prefsNeedsClearKeyBase, userKey);

    final cached = prefs.getStringList(_prefsCacheKeyBase);
    final pending = prefs.getStringList(_prefsPendingKeyBase);
    final needsClear = prefs.getBool(_prefsNeedsClearKeyBase);

    if (cached != null && !prefs.containsKey(cacheKey)) {
      await prefs.setStringList(cacheKey, cached);
    }
    if (pending != null && !prefs.containsKey(pendingKey)) {
      await prefs.setStringList(pendingKey, pending);
    }
    if (needsClear != null && !prefs.containsKey(needsClearKey)) {
      await prefs.setBool(needsClearKey, needsClear);
    }

    for (final key in legacyKeys) {
      await prefs.remove(key);
    }
  }

  static CollectionReference<Map<String, dynamic>>? _historyCollection() {
    if (!_remoteSyncEnabled || !_firebaseReady) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    if (!_userKeyInitialized || _activeUserKey != uid) {
      return null;
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection(_collectionName);
  }

  /// Loads the set of question IDs already used.
  static Future<Set<String>> load() async {
    await _ensureLocalLoaded();
    final targetUserKey = _activeUserKey;
    if (!_remoteSyncEnabled) {
      return Set<String>.from(_memoryCache);
    }

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
      if (_activeUserKey != targetUserKey) {
        return Set<String>.from(_memoryCache);
      }
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
    final previousNeedsRemoteClear = _needsRemoteClear;
    final hadLocalData = _memoryCache.isNotEmpty || _pendingSync.isNotEmpty;
    _memoryCache.clear();
    _pendingSync.clear();
    _needsRemoteClear = true;
    final needsClearChanged = _needsRemoteClear != previousNeedsRemoteClear;
    if (hadLocalData || needsClearChanged) {
      await _persistToLocalStore();
    }
    _scheduleRemoteSync();
  }

  static Future<void> _ensureLocalLoaded() {
    _setupAuthListener();
    _updateActiveUserKey();
    if (_localLoaded) return Future.value();
    return _localLoadFuture ??= _loadFromLocalStore();
  }

  static Future<void> _loadFromLocalStore() async {
    final targetUserKey = _activeUserKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      await _migrateLegacyKeysIfNeeded(prefs, targetUserKey);
      final cacheKey = _scopedPrefsKey(_prefsCacheKeyBase, targetUserKey);
      final pendingKey = _scopedPrefsKey(_prefsPendingKeyBase, targetUserKey);
      final needsClearKey =
          _scopedPrefsKey(_prefsNeedsClearKeyBase, targetUserKey);
      final cached = prefs.getStringList(cacheKey) ?? const <String>[];
      final pending = prefs.getStringList(pendingKey) ?? const <String>[];
      final needsClear = prefs.getBool(needsClearKey) ?? false;

      if (_activeUserKey != targetUserKey) {
        return;
      }

      _memoryCache
        ..clear()
        ..addAll(cached);
      _pendingSync
        ..clear()
        ..addAll(pending);
      _needsRemoteClear = needsClear;
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
      final cacheKey = _scopedPrefsKey(_prefsCacheKeyBase, _activeUserKey);
      final pendingKey = _scopedPrefsKey(_prefsPendingKeyBase, _activeUserKey);
      final needsClearKey =
          _scopedPrefsKey(_prefsNeedsClearKeyBase, _activeUserKey);
      await prefs.setStringList(cacheKey, cacheList);
      await prefs.setStringList(pendingKey, pendingList);
      await prefs.setBool(needsClearKey, _needsRemoteClear);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('QuestionHistoryStore._persistToLocalStore failed: $e\n$st');
      }
    }
  }

  static void _scheduleRemoteSync() {
    if (!_remoteSyncEnabled) {
      return;
    }
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
    final targetUserKey = _activeUserKey;
    try {
      while (true) {
        if (!_remoteSyncEnabled || _activeUserKey != targetUserKey) {
          return;
        }
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
