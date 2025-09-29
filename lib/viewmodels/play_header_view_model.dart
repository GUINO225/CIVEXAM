import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/leaderboard_entry.dart';
import '../services/arcade_progress_store.dart';
import '../services/competition_service.dart';
import '../services/user_profile_service.dart';

class PlayHeaderViewModel extends ChangeNotifier {
  PlayHeaderViewModel({
    Duration? clockTick,
    CompetitionService? competitionService,
    UserProfileService? profileService,
    ArcadeProgressStore? arcadeProgressStore,
  })  : _clockTick = clockTick ?? const Duration(minutes: 1),
        _competitionService = competitionService ?? CompetitionService(),
        _profileService = profileService ?? UserProfileService(),
        _arcadeProgressStore = arcadeProgressStore ?? ArcadeProgressStore();

  final Duration _clockTick;
  final CompetitionService _competitionService;
  final UserProfileService _profileService;
  final ArcadeProgressStore _arcadeProgressStore;

  Timer? _clockTimer;
  bool _started = false;
  bool _disposed = false;

  DateTime _now = DateTime.now();
  String? _profileNickname;
  ArcadeProgressData? _arcadeProgress;
  bool _arcadeProgressLoading = true;
  LeaderboardEntry? _currentUserEntry;
  int? _currentUserRank;

  DateTime get now => _now;
  String? get profileNickname => _profileNickname;
  ArcadeProgressData? get arcadeProgress => _arcadeProgress;
  bool get arcadeProgressLoading => _arcadeProgressLoading;
  LeaderboardEntry? get currentUserEntry => _currentUserEntry;
  int? get currentUserRank => _currentUserRank;

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    _startClock();
    unawaited(loadProfileNickname());
    unawaited(refreshLeaderboard());
    unawaited(loadArcadeProgress());
  }

  Future<void> loadProfileNickname() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e, st) {
      debugPrint('Failed to get SharedPreferences: $e\n$st');
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;

    String? cachedNickname;
    if (prefs != null) {
      final cached = prefs.getString('nickname');
      if (cached != null && cached.trim().isNotEmpty) {
        cachedNickname = cached.trim();
      }
    }

    String? resolvedNickname = cachedNickname;

    if (uid != null) {
      try {
        final profile = await _profileService.loadProfile(uid);
        final trimmed = profile?.nickname.trim();
        if (trimmed != null && trimmed.isNotEmpty) {
          resolvedNickname = trimmed;
          if (prefs != null) {
            await prefs.setString('nickname', trimmed);
          }
        }
      } catch (e, st) {
        debugPrint('Failed to load profile nickname for $uid: $e\n$st');
      }
    }

    if (_disposed) {
      return;
    }

    final nextNickname = resolvedNickname?.trim();
    if (nextNickname != null && nextNickname.isEmpty) {
      if (_profileNickname != null) {
        _profileNickname = null;
        notifyListeners();
      }
      return;
    }

    if (nextNickname != _profileNickname) {
      _profileNickname = nextNickname;
      notifyListeners();
    }
  }

  Future<void> loadArcadeProgress() async {
    if (_disposed) return;
    if (!_arcadeProgressLoading) {
      _arcadeProgressLoading = true;
      notifyListeners();
    }
    try {
      final progress = await _arcadeProgressStore.load();
      if (_disposed) {
        return;
      }
      _arcadeProgress = progress;
      _arcadeProgressLoading = false;
      notifyListeners();
    } catch (e) {
      if (_disposed) {
        return;
      }
      _arcadeProgressLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshLeaderboard() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_disposed) {
      return;
    }
    try {
      LeaderboardEntry? currentEntry;
      int? currentRank;

      final entries = await _competitionService.topEntries(limit: 1000);
      if (uid != null) {
        final index = entries.indexWhere((e) => e.userId == uid);
        if (index >= 0) {
          currentEntry = entries[index];
          currentRank = index + 1;
        } else {
          currentEntry = await _competitionService.entryForUser(uid);
        }
      }

      if (_disposed) {
        return;
      }

      _currentUserEntry = currentEntry;
      _currentUserRank = currentRank;
      notifyListeners();
    } catch (e, st) {
      debugPrint('Failed to refresh leaderboard: $e\n$st');
      if (_disposed) {
        return;
      }
      _currentUserEntry = null;
      _currentUserRank = null;
      notifyListeners();
    }
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(_clockTick, (_) {
      if (_disposed) {
        return;
      }
      _now = DateTime.now();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _clockTimer?.cancel();
    super.dispose();
  }
}
