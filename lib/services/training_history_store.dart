import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/training_history_entry.dart';

class TrainingHistoryStore {
  static const String _prefsKey = 'training_history_entries';
  static const int _maxItems = 100; // conservation des 100 dernières tentatives

  static List<TrainingHistoryEntry> _cache = <TrainingHistoryEntry>[];
  static bool _loaded = false;

  static Future<List<TrainingHistoryEntry>> load() async {
    await _ensureLoaded();
    return List<TrainingHistoryEntry>.from(_cache);
  }

  static Future<void> add(TrainingHistoryEntry entry) async {
    await _ensureLoaded();
    final updated = List<TrainingHistoryEntry>.from(_cache)..add(entry);
    updated.sort((a, b) => b.date.compareTo(a.date));
    _cache = updated.take(_maxItems).toList();
    await _persist();
  }

  static Future<void> clear() async {
    await _ensureLoaded();
    _cache = <TrainingHistoryEntry>[];
    await _persist();
  }

  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefsKey) ?? <String>[];
      _cache = raw
          .map((s) => TrainingHistoryEntry.fromJson(
                jsonDecode(s) as Map<String, dynamic>,
              ))
          .toList();
      _cache.sort((a, b) => b.date.compareTo(a.date));
      if (_cache.length > _maxItems) {
        _cache = _cache.take(_maxItems).toList();
      }
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('TrainingHistoryStore._ensureLoaded failed: $err\n$st');
      }
      _cache = <TrainingHistoryEntry>[];
    }
    _loaded = true;
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized =
          _cache.map((e) => jsonEncode(e.toJson())).toList(growable: false);
      await prefs.setStringList(_prefsKey, serialized);
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('TrainingHistoryStore._persist failed: $err\n$st');
      }
    }
  }
}
