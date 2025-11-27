import 'package:flutter/material.dart';

import 'play_screen.dart';
import 'subject_list_screen.dart';
import 'training_quick_start.dart';

class CycleInfo {
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final Color accent;
  final List<String> subjects;
  final IconData icon;

  const CycleInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.accent,
    required this.subjects,
    required this.icon,
  });
}

const _cycles = <CycleInfo>[
  CycleInfo(
    id: 'cs',
    title: 'Cycle Supérieur',
    subtitle: 'Bac + 4 minimum • Missions stratégiques et décisions publiques',
    color: Color(0xFF3748B4),
    accent: Color(0xFF4E64E8),
    subjects: [
      'Culture générale',
      'Droit public',
      'Administration publique',
      'Analyse documentaire / Résumé',
      'Étude de cas / Note administrative',
      'Anglais',
      'Économie',
    ],
    icon: Icons.workspace_premium_rounded,
  ),
  CycleInfo(
    id: 'cms',
    title: 'Cycle Moyen Supérieur',
    subtitle: 'Bac + 2 • Coordination et suivi opérationnel',
    color: Color(0xFFF29F05),
    accent: Color(0xFFFFB74D),
    subjects: [
      'Culture générale',
      'Droit (constitutionnel + administratif)',
      'Économie',
      'Note de synthèse',
      'Anglais',
      'Mathématiques financières / Analyse',
      'Informatique de base (selon sessions)',
    ],
    icon: Icons.account_tree_rounded,
  ),
  CycleInfo(
    id: 'cm',
    title: 'Cycle Moyen',
    subtitle: 'Baccalauréat • Accès le plus large mais concours très sélectif',
    color: Color(0xFF20A86A),
    accent: Color(0xFF2EC88A),
    subjects: [
      'Culture générale',
      'Français (compréhension, expression, orthographe)',
      'Mathématiques / Logique',
      'Connaissance du civisme et des institutions',
      'Informatique de base (parfois)',
    ],
    icon: Icons.handyman_rounded,
  ),
];

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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisis ton cycle ENA'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.surfaceVariant.withOpacity(0.35),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemBuilder: (context, index) {
            final cycle = _cycles[index];
            return _CycleCard(
              cycle: cycle,
              onTap: () => _openCycle(context, cycle),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemCount: _cycles.length,
        ),
      ),
    );
  }
}

class CycleDetailScreen extends StatelessWidget {
  const CycleDetailScreen({super.key, required this.cycle, this.guestMode = false});

  final CycleInfo cycle;
  final bool guestMode;

  void _startQuickQuiz(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TrainingQuickStartScreen()),
    );
  }

  void _openSubjects(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubjectListScreen()),
    );
  }

  void _openDashboard(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PlayScreen(guestMode: guestMode)),
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

class _CycleCard extends StatelessWidget {
  const _CycleCard({required this.cycle, this.onTap});

  final CycleInfo cycle;
  final VoidCallback? onTap;

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor = theme.colorScheme.onSurface.withOpacity(0.7);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _lighten(cycle.color, 0.3).withOpacity(0.3)),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 8)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cycle.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(cycle.icon, color: cycle.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cycle.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                cycle.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cycle.subjects.take(4).map((s) {
                  return Chip(
                    label: Text(s),
                    backgroundColor: cycle.accent.withOpacity(0.12),
                    labelStyle: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
