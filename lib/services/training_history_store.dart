import '../models/training_history_entry.dart';
import 'local_history_store.dart';

class TrainingHistoryStore {
  static const int _maxItems = 100; // conservation des 100 dernières tentatives

  static Future<List<TrainingHistoryEntry>> load() {
    return loadLocal();
  }

  static Future<List<TrainingHistoryEntry>> loadLocal() async {
    final raw = await LocalHistoryStore.loadTraining();
    return raw
        .map((data) => TrainingHistoryEntry.fromJson(data))
        .toList(growable: false);
  }

  static Future<void> add(TrainingHistoryEntry entry) async {
    final raw = await LocalHistoryStore.loadTraining();
    raw.insert(0, entry.toJson());
    if (raw.length > _maxItems) {
      raw.removeRange(_maxItems, raw.length);
    }
    await LocalHistoryStore.saveTraining(raw);
  }

  static Future<void> clear() async {
    await LocalHistoryStore.clearTraining();
  }
}
