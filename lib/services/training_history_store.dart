import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/training_history_entry.dart';
import 'local_history_persistence.dart';

class TrainingHistoryStore {
  static const int _maxItems = 100; // conservation des 100 dernières tentatives

  static List<TrainingHistoryEntry> _cache = <TrainingHistoryEntry>[];
  static bool _loaded = false;
  static Future<void>? _loadingFuture;
  static bool _listenerRegistered = false;
  static String _activeUserKey = LocalHistoryPersistence.activeUserKey;

  static Future<List<TrainingHistoryEntry>> load() async {
    await _ensureLoaded();
    return List<TrainingHistoryEntry>.from(_cache);
  }

  static Future<void> add(TrainingHistoryEntry entry) async {
    var attempts = 0;
    while (true) {
      attempts++;
      await _ensureLoaded();
      final targetKey = _activeUserKey;
      final updated = List<TrainingHistoryEntry>.from(_cache)..add(entry);
      updated.sort((a, b) => b.date.compareTo(a.date));
      final trimmed = updated.take(_maxItems).toList();
      if (_activeUserKey != targetKey) {
        if (attempts >= 3) {
          return;
        }
        continue;
      }
      _cache = trimmed;
      await _persistFor(targetKey, trimmed);
      return;
    }
  }

  static Future<void> clear() async {
    await _ensureLoaded();
    final targetKey = _activeUserKey;
    _cache = <TrainingHistoryEntry>[];
    try {
      await LocalHistoryPersistence.clearTrainingRaw(targetKey);
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('TrainingHistoryStore.clear failed: $err\n$st');
      }
    }
  }

  static Future<void> _ensureLoaded() async {
    _ensureUserListener();
    if (_loaded) {
      return;
    }
    _loadingFuture ??= _loadFromLocal();
    await _loadingFuture;
  }

  static void _ensureUserListener() {
    if (_listenerRegistered) {
      return;
    }
    _listenerRegistered = true;
    LocalHistoryPersistence.ensureInitialized();
    _activeUserKey = LocalHistoryPersistence.activeUserKey;
    LocalHistoryPersistence.addUserChangeListener(_handleUserChanged);
  }

  static void _handleUserChanged(String newKey) {
    _activeUserKey = newKey;
    _cache = <TrainingHistoryEntry>[];
    _loaded = false;
    _loadingFuture = null;
  }

  static Future<void> _loadFromLocal() async {
    final targetKey = _activeUserKey;
    try {
      final raw = await LocalHistoryPersistence.loadTrainingRaw(targetKey);
      final decoded = <TrainingHistoryEntry>[];
      for (final item in raw) {
        try {
          final map = jsonDecode(item);
          if (map is Map<String, dynamic>) {
            decoded.add(TrainingHistoryEntry.fromJson(map));
          } else if (map is Map) {
            decoded.add(
              TrainingHistoryEntry.fromJson(
                Map<String, dynamic>.from(map as Map<dynamic, dynamic>),
              ),
            );
          }
        } catch (err, st) {
          if (kDebugMode) {
            debugPrint(
              'TrainingHistoryStore._loadFromLocal decode failed: $err\n$st',
            );
          }
        }
      }
      decoded.sort((a, b) => b.date.compareTo(a.date));
      final limited =
          decoded.length > _maxItems ? decoded.take(_maxItems).toList() : decoded;
      if (_activeUserKey != targetKey) {
        return;
      }
      _cache = limited;
      _loaded = true;
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('TrainingHistoryStore._loadFromLocal failed: $err\n$st');
      }
      if (_activeUserKey == targetKey) {
        _cache = <TrainingHistoryEntry>[];
        _loaded = true;
      }
    } finally {
      _loadingFuture = null;
    }
  }

  static Future<void> _persistFor(
    String userKey,
    List<TrainingHistoryEntry> entries,
  ) async {
    try {
      final serialized = entries
          .map((e) => jsonEncode(e.toJson()))
          .toList(growable: false);
      await LocalHistoryPersistence.saveTrainingRaw(userKey, serialized);
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('TrainingHistoryStore._persistFor failed: $err\n$st');
      }
    }
  }
}
