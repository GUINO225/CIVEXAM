import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_history_persistence.dart';

class OngoingQuickQuizState {
  final String title;
  final List<String> questionIds;
  final List<int?> answers;
  final int remainingSeconds;

  OngoingQuickQuizState({
    required this.title,
    required List<String> questionIds,
    required List<int?> answers,
    required int remainingSeconds,
  })  : questionIds = List<String>.unmodifiable(questionIds),
        answers = List<int?>.unmodifiable(_normalizeAnswers(questionIds, answers)),
        remainingSeconds = remainingSeconds < 0 ? 0 : remainingSeconds;

  static List<int?> _normalizeAnswers(
    List<String> questionIds,
    List<int?> source,
  ) {
    final normalized = List<int?>.filled(questionIds.length, null, growable: false);
    for (int i = 0; i < normalized.length && i < source.length; i++) {
      final value = source[i];
      normalized[i] = value;
    }
    return normalized;
  }

  double get completionRatio {
    if (questionIds.isEmpty) {
      return 0.0;
    }
    final answered = answers.where((a) => a != null).length;
    return answered / questionIds.length;
  }

  OngoingQuickQuizState copyWith({
    String? title,
    List<String>? questionIds,
    List<int?>? answers,
    int? remainingSeconds,
  }) {
    final newQuestionIds = questionIds ?? this.questionIds;
    final newAnswers = answers ?? this.answers;
    return OngoingQuickQuizState(
      title: title ?? this.title,
      questionIds: newQuestionIds,
      answers: newAnswers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'questionIds': questionIds,
      'answers': answers,
      'remainingSeconds': remainingSeconds,
    };
  }

  factory OngoingQuickQuizState.fromJson(Map<String, dynamic> json) {
    final rawIds = json['questionIds'];
    final ids = rawIds is List
        ? rawIds.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList(growable: false)
        : const <String>[];
    final rawAnswers = json['answers'];
    final parsedAnswers = <int?>[];
    if (rawAnswers is List) {
      for (final item in rawAnswers) {
        if (item == null) {
          parsedAnswers.add(null);
        } else if (item is num) {
          parsedAnswers.add(item.toInt());
        } else {
          final parsed = int.tryParse(item.toString());
          parsedAnswers.add(parsed);
        }
      }
    }
    final remaining = json['remainingSeconds'];
    final remainingSeconds = remaining is num ? remaining.toInt() : 0;
    final title = json['title']?.toString() ?? 'Entraînement rapide';
    return OngoingQuickQuizState(
      title: title,
      questionIds: ids,
      answers: parsedAnswers,
      remainingSeconds: remainingSeconds,
    );
  }
}

class OngoingQuickQuizStore {
  OngoingQuickQuizStore._();

  static const String _prefsKeyBase = 'ongoing_quick_quiz_state';

  static final ValueNotifier<OngoingQuickQuizState?> notifier =
      ValueNotifier<OngoingQuickQuizState?>(null);

  static OngoingQuickQuizState? _cache;
  static bool _loaded = false;
  static Future<void>? _loadingFuture;
  static bool _listenerRegistered = false;
  static String _activeUserKey = LocalHistoryPersistence.activeUserKey;

  static Future<OngoingQuickQuizState?> load() async {
    await _ensureLoaded();
    return _cache;
  }

  static Future<void> save(OngoingQuickQuizState state) async {
    await _ensureLoaded();
    final targetKey = _activeUserKey;
    try {
      await _persistFor(targetKey, state);
      if (_activeUserKey != targetKey) {
        return;
      }
      _cache = state;
      _notify();
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('OngoingQuickQuizStore.save failed: $err\n$st');
      }
    }
  }

  static Future<void> clear() async {
    await _ensureLoaded();
    final targetKey = _activeUserKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scopedKey(targetKey));
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('OngoingQuickQuizStore.clear failed: $err\n$st');
      }
    }
    if (_activeUserKey == targetKey) {
      _cache = null;
      _notify();
    }
  }

  static void _notify() {
    notifier.value = _cache;
  }

  static Future<void> _ensureLoaded() async {
    _ensureUserListener();
    if (_loaded) {
      return;
    }
    _loadingFuture ??= _loadFromPrefs();
    await _loadingFuture;
  }

  static void _ensureUserListener() {
    if (_listenerRegistered) {
      return;
    }
    _listenerRegistered = true;
    LocalHistoryPersistence.ensureInitialized();
    _activeUserKey = LocalHistoryPersistence.activeUserKey;
    LocalHistoryPersistence.addUserChangeListener(_handleUserChanged);
  }

  static void _handleUserChanged(String newKey) {
    _activeUserKey = newKey;
    _cache = null;
    _loaded = false;
    _loadingFuture = null;
    _notify();
  }

  static Future<void> _loadFromPrefs() async {
    final targetKey = _activeUserKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_scopedKey(targetKey));
      if (_activeUserKey != targetKey) {
        return;
      }
      if (raw == null || raw.isEmpty) {
        _cache = null;
      } else {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _cache = OngoingQuickQuizState.fromJson(decoded);
        } else if (decoded is Map) {
          _cache = OngoingQuickQuizState.fromJson(
            Map<String, dynamic>.from(decoded as Map<dynamic, dynamic>),
          );
        } else {
          _cache = null;
        }
      }
      _loaded = true;
      _notify();
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('OngoingQuickQuizStore._loadFromPrefs failed: $err\n$st');
      }
      if (_activeUserKey == targetKey) {
        _cache = null;
        _loaded = true;
        _notify();
      }
    } finally {
      if (_activeUserKey == targetKey) {
        _loadingFuture = null;
      }
    }
  }

  static Future<void> _persistFor(
    String userKey,
    OngoingQuickQuizState state,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _scopedKey(userKey),
      jsonEncode(state.toJson()),
    );
  }

  static String _scopedKey(String userKey) {
    return '${_prefsKeyBase}_$userKey';
  }
}
