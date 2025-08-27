// lib/services/leaderboard_store.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardStore {
  static const _kKey = 'leaderboard_v1';
  static const int _maxEntries = 100;

  static Future<void> add(LeaderboardEntry e) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kKey) ?? <String>[];
    list.add(json.encode(e.toJson()));
    final entries = list.map((s) =>
      LeaderboardEntry.fromJson(json.decode(s) as Map<String, dynamic>)).toList();
    entries.sort((a, b) {
      final p = b.percent.compareTo(a.percent);
      if (p != 0) return p;
      final d = a.durationSec.compareTo(b.durationSec);
      if (d != 0) return d;
      return b.dateIso.compareTo(a.dateIso);
    });
    final trimmed = entries.take(_maxEntries).toList();
    final encoded = trimmed.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_kKey, encoded);
  }

  static Future<List<LeaderboardEntry>> all() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kKey) ?? <String>[];
    final entries = list.map((s) =>
      LeaderboardEntry.fromJson(json.decode(s) as Map<String, dynamic>)).toList();
    entries.sort((a, b) {
      final p = b.percent.compareTo(a.percent);
      if (p != 0) return p;
      final d = a.durationSec.compareTo(b.durationSec);
      if (d != 0) return d;
      return b.dateIso.compareTo(a.dateIso);
    });
    return entries;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}
