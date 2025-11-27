import 'package:shared_preferences/shared_preferences.dart';

import '../models/cycle_info.dart';

class CycleStore {
  static const _selectedCycleKey = 'selected_cycle_id';

  Future<void> saveSelectedCycle(String cycleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedCycleKey, cycleId);
    } catch (_) {
      // Ignorer les erreurs de cache pour ne pas bloquer l'expérience utilisateur.
    }
  }

  Future<CycleInfo?> loadSelectedCycle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_selectedCycleKey);
      return cycleById(id);
    } catch (_) {
      return null;
    }
  }
}
