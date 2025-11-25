import 'package:flutter/material.dart';

class EnaOverviewScreen extends StatelessWidget {
  const EnaOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide concours ENA'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant.withOpacity(0.35),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _IntroCard(),
              const SizedBox(height: 16),
              _SectionCard(
                title: '1. Les 3 cycles du concours',
                subtitle: 'Chaque cycle correspond à un niveau d\'études et de responsabilité.',
                child: Column(
                  children: const [
                    _CycleTile(
                      label: 'Cycle Supérieur',
                      color: Color(0xFF3748B4),
                      level: 'Bac + 4 minimum',
                      audience: 'Futurs administrateurs civils, inspecteurs, conseillers.',
                      description:
                          'Niveau “élite” : missions stratégiques, analyse et décisions publiques.',
                      icon: Icons.workspace_premium_rounded,
                    ),
                    SizedBox(height: 12),
                    _CycleTile(
                      label: 'Cycle Moyen Supérieur',
                      color: Color(0xFFF29F05),
                      level: 'Bac + 2',
                      audience: 'Attachés administratifs, contrôleurs, responsables intermédiaires.',
                      description:
                          'Pilier opérationnel de l’administration : coordination et suivi.',
                      icon: Icons.account_tree_rounded,
                    ),
                    SizedBox(height: 12),
                    _CycleTile(
                      label: 'Cycle Moyen',
                      color: Color(0xFF20A86A),
                      level: 'Baccalauréat',
                      audience: 'Agents administratifs, assistants et personnels d\'exécution qualifiés.',
                      description:
                          'Cycle le plus accessible mais concours très sélectif.',
                      icon: Icons.handyman_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: '2. Les matières par cycle',
                subtitle: 'Les matières évoluent selon le niveau du cycle.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _SubjectsBlock(
                      title: 'Cycle Supérieur',
                      color: Color(0xFF3748B4),
                      subjects: [
                        'Culture générale',
                        'Droit public',
                        'Administration publique',
                        'Analyse documentaire / Résumé',
                        'Étude de cas / Note administrative',
                        'Anglais',
                        'Économie',
                      ],
                    ),
                    SizedBox(height: 12),
                    _SubjectsBlock(
                      title: 'Cycle Moyen Supérieur',
                      color: Color(0xFFF29F05),
                      subjects: [
                        'Culture générale',
                        'Droit (constitutionnel + administratif)',
                        'Économie',
                        'Note de synthèse',
                        'Anglais',
                        'Mathématiques financières / Analyse',
                        'Informatique de base (selon sessions)',
                      ],
                    ),
                    SizedBox(height: 12),
                    _SubjectsBlock(
                      title: 'Cycle Moyen',
                      color: Color(0xFF20A86A),
                      subjects: [
                        'Culture générale',
                        'Français (compréhension, expression, orthographe)',
                        'Mathématiques / Logique',
                        'Connaissance du civisme et des institutions',
                        'Informatique de base (parfois)',
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: '3. Déroulement des épreuves',
                subtitle: 'Chaque matière est une épreuve séparée avec un horaire précis.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _BulletRow(
                      icon: Icons.event_available_rounded,
                      text:
                          'Les épreuves sont séparées : une matière = une épreuve dédiée, pas un « bouillon de matières » dans une seule salle.',
                    ),
                    SizedBox(height: 8),
                    _BulletRow(
                      icon: Icons.schedule_rounded,
                      text:
                          'Chaque matière se déroule sur un créneau précis (matin ou après-midi) avec une durée définie.',
                    ),
                    SizedBox(height: 8),
                    _BulletRow(
                      icon: Icons.calendar_today_rounded,
                      text:
                          'Les horaires varient selon les sessions, mais on reste sur un format écrit par matière.',
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Durées écrites habituelles :',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    _TimingGrid(),
                    SizedBox(height: 12),
                    Text(
                      'Exemple d\'emploi du temps (indicatif) :',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    _ScheduleTable(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.12),
              theme.colorScheme.primary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.school_rounded,
                      color: theme.colorScheme.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "L'ENA forme les hauts cadres de l'État. Le concours est organisé en trois cycles : chacun associe un niveau d'études à un niveau de responsabilité.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Découvre en un coup d’œil le cycle qui te correspond, les matières associées et comment se déroulent les épreuves.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _CycleTile extends StatelessWidget {
  final String label;
  final Color color;
  final String level;
  final String audience;
  final String description;
  final IconData icon;

  const _CycleTile({
    required this.label,
    required this.color,
    required this.level,
    required this.audience,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35), width: 1.2),
        color: color.withOpacity(0.08),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _LevelChip(text: level, color: color),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  audience,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String text;
  final Color color;

  const _LevelChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color.darken(),
            ) ??
            TextStyle(color: color.darken(), fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 26),
    );
  }
}

class _SubjectsBlock extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> subjects;

  const _SubjectsBlock({
    required this.title,
    required this.color,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.35), width: 1.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...subjects.map(
            (subject) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subject,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BulletRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withOpacity(0.35)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _TimingGrid extends StatelessWidget {
  const _TimingGrid();

  @override
  Widget build(BuildContext context) {
    const timings = <String, String>{
      'Culture générale': '3 h',
      'Droit': '2 à 3 h',
      'Économie': '2 h',
      'Mathématiques / Logique': '2 h',
      'Français': '2 à 3 h',
      'Note de synthèse / résumé': '3 h',
      'Anglais': '1 h 30',
      'Étude de cas / Note administrative': '3 h',
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 520;
        final items = timings.entries.toList();
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((entry) {
            return SizedBox(
              width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
              child: _TimingTile(label: entry.key, duration: entry.value),
            );
          }).toList(),
        );
      },
    );
  }
}

class _TimingTile extends StatelessWidget {
  final String label;
  final String duration;

  const _TimingTile({
    required this.label,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.timer_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(duration, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ScheduleTable extends StatelessWidget {
  const _ScheduleTable();

  @override
  Widget build(BuildContext context) {
    final rows = const [
      _ScheduleRow(day: 'Jour 1', morning: 'Culture générale', afternoon: 'Droit'),
      _ScheduleRow(day: 'Jour 2', morning: 'Économie', afternoon: 'Anglais'),
      _ScheduleRow(day: 'Jour 3', morning: 'Note de synthèse', afternoon: 'Étude de cas'),
      _ScheduleRow(day: 'Jour 4', morning: 'Mathématiques / Logique', afternoon: 'Informatique'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          _ScheduleHeader(),
          ...rows,
        ],
      ),
    );
  }
}

class _ScheduleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.12),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _HeaderCell('Jour', flex: 2),
          _HeaderCell('Matin', flex: 4),
          _HeaderCell('Après-midi', flex: 4),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String day;
  final String morning;
  final String afternoon;

  const _ScheduleRow({
    required this.day,
    required this.morning,
    required this.afternoon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.35)),
        ),
      ),
      child: Row(
        children: [
          _BodyCell(day, flex: 2, isEmphasis: true),
          _BodyCell(morning, flex: 4),
          _BodyCell(afternoon, flex: 4),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isEmphasis;

  const _BodyCell(this.text, {required this.flex, this.isEmphasis = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: isEmphasis ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

extension on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
