import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/training_history_entry.dart';

class TrainingHistoryStore {
  static const String _key = 'trainingHistoryV2';
  static const int _maxItems = 100; // conservation des 100 dernières tentatives

  static Future<List<TrainingHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    // V2
    final raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        return list.map(TrainingHistoryEntry.fromJson).toList();
      } catch (_) {
        // fallthrough: tente de lire l'ancienne clé si nécessaire
      }
    }
    // Compat: ancienne clé (si migration)
    final legacy = prefs.getString('trainingHistoryV1');
    if (legacy != null && legacy.isNotEmpty) {
      try {
        final list = (jsonDecode(legacy) as List).cast<Map<String, dynamic>>();
        final items = list.map(TrainingHistoryEntry.fromJson).toList();
        // Sauvegarde au nouveau format sans TTL
        await _save(items);
        await prefs.remove('trainingHistoryV1');
        return items;
      } catch (_) {}
    }
    return <TrainingHistoryEntry>[];
  }

  static Future<void> add(TrainingHistoryEntry entry) async {
    final list = await load();
    list.insert(0, entry);
    // Garde seulement les _maxItems plus récents
    if (list.length > _maxItems) {
      list.removeRange(_maxItems, list.length);
    }
    await _save(list);
  }

  static Future<void> _save(List<TrainingHistoryEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
