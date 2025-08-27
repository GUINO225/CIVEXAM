import 'package:shared_preferences/shared_preferences.dart';
import '../models/exam_history_entry.dart';

class HistoryStore {
  static const String _key = 'examHistoryV1';

  static Future<List<ExamHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <ExamHistoryEntry>[];
    try {
      return ExamHistoryEntry.decodeList(raw);
    } catch (_) {
      return <ExamHistoryEntry>[];
    }
  }

  static Future<void> add(ExamHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await load();
    list.insert(0, entry); // plus récent en premier
    await prefs.setString(_key, ExamHistoryEntry.encodeList(list));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
