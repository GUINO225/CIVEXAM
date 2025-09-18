import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility to persist history data locally per-user.
class LocalHistoryStore {
  static const String _trainingKeySuffix = 'trainingHistory';
  static const String _examKeySuffix = 'examHistory';

  /// Loads locally stored training history entries as raw maps.
  static Future<List<Map<String, dynamic>>> loadTraining() {
    return _loadList(_trainingKeySuffix);
  }

  /// Persists the provided training history payload locally.
  static Future<void> saveTraining(List<Map<String, dynamic>> payload) {
    return _saveList(_trainingKeySuffix, payload);
  }

  /// Clears the locally stored training history payload.
  static Future<void> clearTraining() {
    return _clear(_trainingKeySuffix);
  }

  /// Loads locally stored exam history entries as raw maps.
  static Future<List<Map<String, dynamic>>> loadExam() {
    return _loadList(_examKeySuffix);
  }

  /// Persists the provided exam history payload locally.
  static Future<void> saveExam(List<Map<String, dynamic>> payload) {
    return _saveList(_examKeySuffix, payload);
  }

  /// Clears the locally stored exam history payload.
  static Future<void> clearExam() {
    return _clear(_examKeySuffix);
  }

  static Future<List<Map<String, dynamic>>> _loadList(String suffix) async {
    final key = _buildKey(suffix);
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(key);
      if (stored == null || stored.isEmpty) {
        return <Map<String, dynamic>>[];
      }
      final result = <Map<String, dynamic>>[];
      for (final entry in stored) {
        try {
          final decoded = jsonDecode(entry);
          if (decoded is Map<String, dynamic>) {
            result.add(Map<String, dynamic>.from(decoded));
          } else if (decoded is Map) {
            result.add(Map<String, dynamic>.from(
                decoded.map((key, value) => MapEntry(key.toString(), value))));
          }
        } catch (err, st) {
          if (kDebugMode) {
            debugPrint('LocalHistoryStore._loadList decode failed: $err\n$st');
          }
        }
      }
      return result;
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('LocalHistoryStore._loadList failed: $err\n$st');
      }
      return <Map<String, dynamic>>[];
    }
  }

  static Future<void> _saveList(
      String suffix, List<Map<String, dynamic>> payload) async {
    final key = _buildKey(suffix);
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = payload.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList(key, encoded);
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('LocalHistoryStore._saveList failed: $err\n$st');
      }
    }
  }

  static Future<void> _clear(String suffix) async {
    final key = _buildKey(suffix);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('LocalHistoryStore._clear failed: $err\n$st');
      }
    }
  }

  static String _buildKey(String suffix) {
    String uid = 'guest';
    try {
      final current = FirebaseAuth.instance.currentUser;
      if (current != null && current.uid.isNotEmpty) {
        uid = current.uid;
      }
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('LocalHistoryStore._buildKey failed: $err\n$st');
      }
    }
    return '${uid}_$suffix';
  }
}
