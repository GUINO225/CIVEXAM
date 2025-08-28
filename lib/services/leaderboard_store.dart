// lib/services/leaderboard_store.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardStore {
  static const _kKey = 'leaderboard_v1';
  static const int _maxEntries = 100;

  static List<LeaderboardEntry> _sortEntries(
      List<LeaderboardEntry> entries) {
    entries.sort((a, b) {
      final p = b.percent.compareTo(a.percent);
      if (p != 0) return p;
      final d = a.durationSec.compareTo(b.durationSec);
      if (d != 0) return d;
      return b.dateIso.compareTo(a.dateIso);
    });
    return entries.take(_maxEntries).toList();
  }

  static Future<void> add(LeaderboardEntry e) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kKey) ?? <String>[];
    list.add(json.encode(e.toJson()));
    final entries = <LeaderboardEntry>[];
    for (final s in list) {
      try {
        entries.add(
            LeaderboardEntry.fromJson(json.decode(s) as Map<String, dynamic>));
      } catch (_) {
        // ignore invalid stored entries
      }
    }
    final sorted = _sortEntries(entries);
    final encoded = sorted.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_kKey, encoded);
  }

  static Future<List<LeaderboardEntry>> all() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kKey) ?? <String>[];
    final entries = <LeaderboardEntry>[];
    for (final s in list) {
      try {
        entries.add(
            LeaderboardEntry.fromJson(json.decode(s) as Map<String, dynamic>));
      } catch (_) {
        // ignore invalid stored entries
      }
    }
    return _sortEntries(entries);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
