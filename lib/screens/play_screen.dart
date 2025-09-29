import 'package:flutter/material.dart';

import '../widgets/play_bottom_navigation.dart';
import '../widgets/play_themed_scaffold.dart';
import 'dashboard_screen.dart';
import 'design_settings_screen.dart';
import 'exam_history_screen.dart';
import 'multi_exam_flow.dart';
import 'profile_edit_screen.dart';
import 'training_quick_start.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({
    super.key,
    this.initialTabIndex = kPlayBottomNavQuizIndex,
  });

  final int initialTabIndex;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final List<WidgetBuilder> _tabBuilders;
  final Map<int, Widget> _tabCache = <int, Widget>{};

  late int _bodyIndex;
  late int _navIndex;

  @override
  void initState() {
    super.initState();

    _tabBuilders = <WidgetBuilder>[
      (_) => const TrainingQuickStartScreen(),
      (_) => const DashboardScreen(),
      (_) => const MultiExamFlowScreen(),
      (_) => const ExamHistoryScreen(),
      (_) => const ProfileEditScreen(),
      (_) => const DesignSettingsScreen(),
    ];

    final int normalizedIndex =
        widget.initialTabIndex.clamp(0, _tabBuilders.length - 1) as int;

    if (normalizedIndex == kPlayBottomNavQuizIndex) {
      _bodyIndex = 0;
      _navIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openQuiz(previousNavIndex: _bodyIndex);
      });
    } else {
      _bodyIndex = normalizedIndex;
      _navIndex = normalizedIndex;
    }
  }

  void _openQuiz({required int previousNavIndex}) {
    setState(() {
      _navIndex = kPlayBottomNavQuizIndex;
    });
    Navigator.of(context)
        .push(MaterialPageRoute(builder: _tabBuilders[kPlayBottomNavQuizIndex]))
        .whenComplete(() {
      if (!mounted) return;
      setState(() {
        _navIndex = previousNavIndex;
      });
    });
  }

  void _handleBottomNavSelection(int index) {
    if (index == kPlayBottomNavQuizIndex) {
      _openQuiz(previousNavIndex: _bodyIndex);
      return;
    }

    if (_bodyIndex == index && _navIndex == index) {
      return;
    }

    setState(() {
      _bodyIndex = index;
      _navIndex = index;
    });
  }

  Widget _buildCurrentTab(BuildContext context) {
    return _tabCache.putIfAbsent(
      _bodyIndex,
      () => _tabBuilders[_bodyIndex](context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlayThemedScaffold(
      body: _buildCurrentTab(context),
      bottomNavigationBar: PlayBottomNavigationBar(
        items: kPlayBottomNavDestinations,
        selectedIndex: _navIndex,
        showFabNotch: false,
        onItemSelected: _handleBottomNavSelection,
      ),
    );
  }
}
