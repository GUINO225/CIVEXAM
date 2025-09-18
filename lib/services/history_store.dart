import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../models/exam_history_entry.dart';
import 'local_history_persistence.dart';

class HistoryStore {
  static List<ExamHistoryEntry> _cache = <ExamHistoryEntry>[];
  static bool _loaded = false;
  static Future<void>? _loadingFuture;
  static bool _listenerRegistered = false;
  static String _activeUserKey = LocalHistoryPersistence.activeUserKey;

  static Future<List<ExamHistoryEntry>> load() async {
    await _ensureLoaded();
    return List<ExamHistoryEntry>.from(_cache);
  }

  static Future<void> add(ExamHistoryEntry entry) async {
    var attempts = 0;
    while (true) {
      attempts++;
      await _ensureLoaded();
      final targetKey = _activeUserKey;
      final updated = <ExamHistoryEntry>[entry, ..._cache];
      if (_activeUserKey != targetKey) {
        if (attempts >= 3) {
          return;
        }
        continue;
      }
      _cache = updated;
      await _persistFor(targetKey, updated);
      return;
    }
  }

  static Future<void> clear() async {
    await _ensureLoaded();
    final targetKey = _activeUserKey;
    _cache = <ExamHistoryEntry>[];
    try {
      await LocalHistoryPersistence.clearExamRaw(targetKey);
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('HistoryStore.clear failed: $err\n$st');
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
    _cache = <ExamHistoryEntry>[];
    _loaded = false;
    _loadingFuture = null;
  }

  static Future<void> _loadFromLocal() async {
    final targetKey = _activeUserKey;
    try {
      final raw = await LocalHistoryPersistence.loadExamRaw(targetKey);
      final entries = <ExamHistoryEntry>[];
      for (final item in raw) {
        try {
          final decoded = jsonDecode(item);
          if (decoded is Map<String, dynamic>) {
            entries.add(ExamHistoryEntry.fromJson(decoded));
          } else if (decoded is Map) {
            entries.add(
              ExamHistoryEntry.fromJson(
                Map<String, dynamic>.from(decoded as Map<dynamic, dynamic>),
              ),
            );
          }
        } catch (err, st) {
          if (kDebugMode) {
            debugPrint('HistoryStore._loadFromLocal decode failed: $err\n$st');
          }
        }
      }
      if (_activeUserKey != targetKey) {
        return;
      }
      _cache = entries;
      _loaded = true;
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('HistoryStore._loadFromLocal failed: $err\n$st');
      }
      if (_activeUserKey == targetKey) {
        _cache = <ExamHistoryEntry>[];
        _loaded = true;
      }
    } finally {
      _loadingFuture = null;
    }
  }

  static Future<void> _persistFor(
    String userKey,
    List<ExamHistoryEntry> entries,
  ) async {
    try {
      final serialized = entries
          .map((e) => jsonEncode(_serializeEntry(e)))
          .toList(growable: false);
      await LocalHistoryPersistence.saveExamRaw(userKey, serialized);
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('HistoryStore._persistFor failed: $err\n$st');
      }
    }
  }

  static Map<String, dynamic> _serializeEntry(ExamHistoryEntry entry) => {
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
