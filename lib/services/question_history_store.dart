import 'package:shared_preferences/shared_preferences.dart';

/// Persists IDs of questions already used so we can avoid repetitions
/// across quiz sessions.
class QuestionHistoryStore {
  static const String _key = 'questionHistoryV1';

  /// Loads the set of question IDs already used.
  static Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key);
    if (list == null || list.isEmpty) return <String>{};
    return list.toSet();
  }

  /// Adds a single question ID to the history store.
  static Future<void> add(String id) async {
    final ids = await load();
    ids.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }

  /// Adds multiple question IDs to the history store.
  static Future<void> addAll(Iterable<String> ids) async {
    final current = await load();
    current.addAll(ids);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, current.toList());
  }

  /// Clears the stored question IDs.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
