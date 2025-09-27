import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_history_persistence.dart';

class QuickQuizSummary {
  final String title;
  final DateTime completedAt;
  final int correctAnswers;
  final int totalQuestions;

  const QuickQuizSummary({
    required this.title,
    required this.completedAt,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  double get percent {
    if (totalQuestions <= 0) {
      return 0.0;
    }
    return (correctAnswers / totalQuestions) * 100.0;
  }

  double get completionRatio => percent / 100.0;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'completedAt': completedAt.toIso8601String(),
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
    };
  }

  factory QuickQuizSummary.fromJson(Map<String, dynamic> json) {
    final rawDate = json['completedAt'];
    DateTime completedAt;
    if (rawDate is String) {
      completedAt = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is int) {
      completedAt = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      completedAt = DateTime.now();
    }
    return QuickQuizSummary(
      title: json['title']?.toString() ?? 'Entraînement rapide',
      completedAt: completedAt,
      correctAnswers: json['correctAnswers'] is num
          ? (json['correctAnswers'] as num).toInt()
          : int.tryParse(json['correctAnswers']?.toString() ?? '') ?? 0,
      totalQuestions: json['totalQuestions'] is num
          ? (json['totalQuestions'] as num).toInt()
          : int.tryParse(json['totalQuestions']?.toString() ?? '') ?? 0,
    );
  }
}

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
  static const String _prefsKeyLastBase = 'ongoing_quick_quiz_state_last';

  static final ValueNotifier<OngoingQuickQuizState?> notifier =
      ValueNotifier<OngoingQuickQuizState?>(null);
  static final ValueNotifier<QuickQuizSummary?> lastResultNotifier =
      ValueNotifier<QuickQuizSummary?>(null);

  static OngoingQuickQuizState? _cache;
  static QuickQuizSummary? _lastResultCache;
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
      _notifyState();
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
      _notifyState();
    }
  }

  static Future<void> saveLastResult(QuickQuizSummary summary) async {
    await _ensureLoaded();
    final targetKey = _activeUserKey;
    try {
      await _persistSummaryFor(targetKey, summary);
      if (_activeUserKey != targetKey) {
        return;
      }
      _lastResultCache = summary;
      _notifyLastResult();
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('OngoingQuickQuizStore.saveLastResult failed: $err\n$st');
      }
    }
  }

  static Future<void> clearLastResult() async {
    await _ensureLoaded();
    final targetKey = _activeUserKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scopedLastKey(targetKey));
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('OngoingQuickQuizStore.clearLastResult failed: $err\n$st');
      }
    }
    if (_activeUserKey == targetKey) {
      _lastResultCache = null;
      _notifyLastResult();
    }
  }

  static void _notifyState() {
    notifier.value = _cache;
  }

  static void _notifyLastResult() {
    lastResultNotifier.value = _lastResultCache;
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
    _lastResultCache = null;
    _loaded = false;
    _loadingFuture = null;
    _notifyState();
    _notifyLastResult();
  }

  static Future<void> _loadFromPrefs() async {
    final targetKey = _activeUserKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_scopedKey(targetKey));
      final rawLast = prefs.getString(_scopedLastKey(targetKey));
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
      if (rawLast == null || rawLast.isEmpty) {
        _lastResultCache = null;
      } else {
        final decoded = jsonDecode(rawLast);
        if (decoded is Map<String, dynamic>) {
          _lastResultCache = QuickQuizSummary.fromJson(decoded);
        } else if (decoded is Map) {
          _lastResultCache = QuickQuizSummary.fromJson(
            Map<String, dynamic>.from(decoded as Map<dynamic, dynamic>),
          );
        } else {
          _lastResultCache = null;
        }
      }
      _loaded = true;
      _notifyState();
      _notifyLastResult();
    } catch (err, st) {
      if (kDebugMode) {
        debugPrint('OngoingQuickQuizStore._loadFromPrefs failed: $err\n$st');
      }
      if (_activeUserKey == targetKey) {
        _cache = null;
        _lastResultCache = null;
        _loaded = true;
        _notifyState();
        _notifyLastResult();
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

  static Future<void> _persistSummaryFor(
    String userKey,
    QuickQuizSummary summary,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _scopedLastKey(userKey),
      jsonEncode(summary.toJson()),
    );
  }

  static String _scopedKey(String userKey) {
    return '${_prefsKeyBase}_$userKey';
  }

  static String _scopedLastKey(String userKey) {
    return '${_prefsKeyLastBase}_$userKey';
  }
}
