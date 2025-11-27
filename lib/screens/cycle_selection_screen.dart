import 'dart:async';
import 'package:flutter/material.dart';

import '../models/cycle_info.dart';
import '../services/cycle_store.dart';
import '../widgets/play_bottom_nav_bar.dart';
import 'play_screen.dart';
import 'subject_list_screen.dart';
import 'training_quick_start.dart';

class CycleSelectionScreen extends StatelessWidget {
  const CycleSelectionScreen({super.key, this.guestMode = false});

  final bool guestMode;

  void _openCycle(BuildContext context, CycleInfo cycle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CycleDetailScreen(cycle: cycle, guestMode: guestMode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.colorScheme.primary;
    final onBrand = theme.colorScheme.onPrimary;
    final navHighlight = Color.alphaBlend(onBrand.withOpacity(0.14), brand);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      bottomNavigationBar: PlayBottomNavBar(
        destinations: playNavDestinations,
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 0) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PlayScreen(initialIndex: index)),
          );
        },
        backgroundColor: brand,
        highlightColor: navHighlight,
        foregroundColor: onBrand,
      ),
      body: Column(
        children: [
          _PlayHeader(brand: brand, onBrand: onBrand),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final cycle in enaCycles)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: _CycleCard(
                              cycle: cycle,
                              onTap: () => _openCycle(context, cycle),
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CycleDetailScreen extends StatelessWidget {
  const CycleDetailScreen({super.key, required this.cycle, this.guestMode = false});

  final CycleInfo cycle;
  final bool guestMode;

  Future<void> _rememberCycle() {
    return CycleStore().saveSelectedCycle(cycle.id);
  }

  Future<void> _startQuickQuiz(BuildContext context) async {
    await _rememberCycle();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrainingQuickStartScreen(
          cycleName: cycle.title,
          subjectWhitelist: cycle.subjects,
        ),
      ),
    );
  }

  Future<void> _openSubjects(BuildContext context) async {
    await _rememberCycle();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubjectListScreen(
          allowedSubjects: cycle.subjects,
          cycleName: cycle.title,
        ),
      ),
    );
  }

  Future<void> _openDashboard(BuildContext context) async {
    await _rememberCycle();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PlayScreen(cycle: cycle, guestMode: guestMode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final onColor = Colors.white;
    final subtitleColor = theme.colorScheme.onSurface.withOpacity(0.72);

    return Scaffold(
      appBar: AppBar(
        title: Text(cycle.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cycle.color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 16,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(cycle.icon, color: onColor, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cycle.title,
                          style: textTheme.headlineSmall?.copyWith(
                            color: onColor,
                            fontWeight: FontWeight.w900,
                          ) ??
                              TextStyle(
                                color: onColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cycle.subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: onColor.withOpacity(0.9),
                    ) ??
                        TextStyle(
                          color: onColor.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Matières clés',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Voici les matières généralement associées à ce cycle. Sélectionne une matière pour t\'entraîner et réviser par thème.',
              style: textTheme.bodyMedium?.copyWith(color: subtitleColor),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cycle.subjects
                  .map(
                    (s) => Chip(
                  label: Text(s),
                  backgroundColor: cycle.accent.withOpacity(0.12),
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cycle.accent.withOpacity(0.16),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.quiz_rounded, color: cycle.color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Quiz et entraînements',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cycle.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entraîne-toi immédiatement ou explore toutes les matières disponibles.',
                          style: textTheme.bodyMedium?.copyWith(color: subtitleColor),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow_rounded),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cycle.color,
                            foregroundColor: onColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _startQuickQuiz(context),
                          label: const Text('Lancer un quiz rapide'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.menu_book_rounded),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _openSubjects(context),
                          label: const Text('Explorer toutes les matières'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Prêt pour le tableau de bord ? Passe au Play Screen pour découvrir les autres modes de révision.',
              style: textTheme.bodyMedium?.copyWith(color: subtitleColor),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              icon: const Icon(Icons.dashboard_customize_rounded),
              style: FilledButton.styleFrom(
                backgroundColor: cycle.color,
                foregroundColor: onColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _openDashboard(context),
              label: const Text('Continuer vers le Play Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayHeader extends StatelessWidget {
  const _PlayHeader({required this.brand, required this.onBrand});

  final Color brand;
  final Color onBrand;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 18 ? 'Bienvenue' : 'Bonsoir';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: brand,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: onBrand.withOpacity(0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sélection du cycle ENA',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: onBrand,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                greeting,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: onBrand.withOpacity(0.9),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choisis ton cycle pour continuer',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onBrand.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleCard extends StatelessWidget {
  const _CycleCard({required this.cycle, this.onTap});

  final CycleInfo cycle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 10)),
          ],
          border: Border.all(color: cycle.color.withOpacity(0.14)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cycle.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(cycle.icon, color: cycle.color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              cycle.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
