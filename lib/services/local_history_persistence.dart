import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles user-scoped persistence for exam and training history entries.
///
/// Data is stored locally (via [SharedPreferences]) and keyed by the current
/// Firebase user identifier. When no user is authenticated we fall back to a
/// local-only namespace so data remains available offline but isolated per
/// account once a user logs in.
class LocalHistoryPersistence {
  LocalHistoryPersistence._();

  static const String _examKeyBase = 'exam_history_entries';
  static const String _trainingKeyBase = 'training_history_entries';
  static const String _defaultUserKey = 'local';

  static final List<void Function(String)> _listeners =
      <void Function(String)>[];

  static bool _initialized = false;
  static String _activeUserKey = _defaultUserKey;
  static StreamSubscription<User?>? _authSubscription;

  /// Ensures the persistence layer is ready and listening for auth changes.
  static void ensureInitialized() {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _activeUserKey = _resolveCurrentUserKey();
    _setupAuthListener();
  }

  /// Returns the user key currently in use for local storage.
  static String get activeUserKey {
    ensureInitialized();
    return _activeUserKey;
  }

  /// Registers a callback invoked whenever the active user key changes.
  static void addUserChangeListener(void Function(String newKey) listener) {
    ensureInitialized();
    if (_listeners.contains(listener)) {
      return;
    }
    _listeners.add(listener);
  }

  /// Removes a previously registered user change listener.
  static void removeUserChangeListener(void Function(String) listener) {
    _listeners.remove(listener);
  }

  /// Loads the raw serialized exam history entries for the given [userKey].
  static Future<List<String>> loadExamRaw(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyExamIfNeeded(prefs, userKey);
    return prefs.getStringList(_scopedKey(_examKeyBase, userKey)) ??
        const <String>[];
  }

  /// Persists the raw serialized exam history [entries] for [userKey].
  static Future<void> saveExamRaw(
    String userKey,
    List<String> entries,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_scopedKey(_examKeyBase, userKey), entries);
  }

  /// Clears all locally stored exam history entries for [userKey].
  static Future<void> clearExamRaw(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scopedKey(_examKeyBase, userKey));
  }

  /// Loads the raw serialized training history entries for [userKey].
  static Future<List<String>> loadTrainingRaw(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyTrainingIfNeeded(prefs, userKey);
    return prefs.getStringList(_scopedKey(_trainingKeyBase, userKey)) ??
        const <String>[];
  }

  /// Persists the raw serialized training history [entries] for [userKey].
  static Future<void> saveTrainingRaw(
    String userKey,
    List<String> entries,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_scopedKey(_trainingKeyBase, userKey), entries);
  }

  /// Clears all locally stored training history entries for [userKey].
  static Future<void> clearTrainingRaw(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scopedKey(_trainingKeyBase, userKey));
  }

  static void _setupAuthListener() {
    if (_authSubscription != null) {
      return;
    }
    try {
      _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
        (User? user) {
          final newKey = _userKeyFromUid(user?.uid);
          if (newKey == _activeUserKey) {
            return;
          }
          _activeUserKey = newKey;
          for (final listener in List<void Function(String)>.from(_listeners)) {
            try {
              listener(newKey);
            } catch (err, st) {
              if (kDebugMode) {
                debugPrint(
                  'LocalHistoryPersistence listener failed: $err\n$st',
                );
              }
            }
          }
        },
        onError: (Object error, StackTrace st) {
          if (kDebugMode) {
            debugPrint(
              'LocalHistoryPersistence auth listener error: $error\n$st',
            );
          }
        },
      );
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('LocalHistoryPersistence setup failed: $err\n$st');
      }
    }
  }

  static Future<void> _migrateLegacyExamIfNeeded(
    SharedPreferences prefs,
    String userKey,
  ) async {
    if (userKey != _defaultUserKey) {
      return;
    }
    final legacyKey = _examKeyBase;
    final scopedKey = _scopedKey(_examKeyBase, userKey);
    if (!prefs.containsKey(legacyKey) || prefs.containsKey(scopedKey)) {
      return;
    }
    final data = prefs.getStringList(legacyKey);
    if (data != null) {
      await prefs.setStringList(scopedKey, data);
    }
    await prefs.remove(legacyKey);
  }

  static Future<void> _migrateLegacyTrainingIfNeeded(
    SharedPreferences prefs,
    String userKey,
  ) async {
    if (userKey != _defaultUserKey) {
      return;
    }
    final legacyKey = _trainingKeyBase;
    final scopedKey = _scopedKey(_trainingKeyBase, userKey);
    if (!prefs.containsKey(legacyKey) || prefs.containsKey(scopedKey)) {
      return;
    }
    final data = prefs.getStringList(legacyKey);
    if (data != null) {
      await prefs.setStringList(scopedKey, data);
    }
    await prefs.remove(legacyKey);
  }

  static String _resolveCurrentUserKey() {
    try {
      return _userKeyFromUid(FirebaseAuth.instance.currentUser?.uid);
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

  static String _scopedKey(String base, String userKey) {
    return '${base}_$userKey';
  }
}
