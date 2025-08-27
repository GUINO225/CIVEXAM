import 'package:shared_preferences/shared_preferences.dart';

class TrainingPrefs {
  static const String _kDuration = 'trainingDurationMinutes';

  static Future<void> saveDurationMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDuration, minutes);
  }

  static Future<int?> getDurationMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kDuration);
  }
}
