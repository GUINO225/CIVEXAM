import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/leaderboard_entry.dart';

/// Stocke localement les scores privés (ex: entraînement) pour l’affichage
/// dans l’application sans remonter les données sur Firestore.
class PrivateScoresStore {
  static const String _prefsKey = 'private_scores_entries';
  static const int _maxEntries = 100;

  static List<LeaderboardEntry> _cache = <LeaderboardEntry>[];
  static bool _loaded = false;

  static Future<void> add(LeaderboardEntry entry) async {
    await _ensureLoaded();
    final updated = List<LeaderboardEntry>.from(_cache)..add(entry);
    updated.sort(_compareEntries);
    _cache = updated.take(_maxEntries).toList();
    await _persist();
  }

  static Future<List<LeaderboardEntry>> load() async {
    await _ensureLoaded();
    return List<LeaderboardEntry>.from(_cache);
  }

  static Future<void> clear() async {
    await _ensureLoaded();
    _cache = <LeaderboardEntry>[];
    await _persist();
  }

  static Future<void> _ensureLoaded() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefsKey) ?? <String>[];
      _cache = raw
          .map((s) => LeaderboardEntry.fromJson(
                jsonDecode(s) as Map<String, dynamic>,
              ))
          .toList();
      _cache.sort(_compareEntries);
      if (_cache.length > _maxEntries) {
        _cache = _cache.take(_maxEntries).toList();
      }
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('PrivateScoresStore._ensureLoaded failed: $err\n$st');
      }
      _cache = <LeaderboardEntry>[];
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
        debugPrint('PrivateScoresStore._persist failed: $err\n$st');
      }
    }
  }

  static int _compareEntries(LeaderboardEntry a, LeaderboardEntry b) {
    final percentCompare = b.percent.compareTo(a.percent);
    if (percentCompare != 0) {
      return percentCompare;
    }
    final durationCompare = a.durationSec.compareTo(b.durationSec);
    if (durationCompare != 0) {
      return durationCompare;
    }
    return b.dateIso.compareTo(a.dateIso);
  }
}
