// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/competition_service.dart';
import '../utils/arcade_level_utils.dart';
import '../utils/rank_display_helper.dart';
import '../widgets/arcade_badge_chip.dart';
import '../widgets/play_themed_scaffold.dart';

enum _Period { weekly, allTime }

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const Color _brand = Color(0xFF5336C6);

  List<LeaderboardEntry> _entries = const [];
  String _query = '';
  _Period _period = _Period.allTime;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final competitionService = CompetitionService();
    await competitionService.purgeLegacyEntries();
    final comp = await competitionService.topEntries(); // TODO: accepter un paramètre de période si dispo
    comp.sort((a, b) {
      final percentCompare = b.percent.compareTo(a.percent);
      if (percentCompare != 0) return percentCompare;
      return a.durationSec.compareTo(b.durationSec);
    });
    if (!mounted) return;
    setState(() => _entries = comp);
  }

  List<LeaderboardEntry> get _filtered {
    Iterable<LeaderboardEntry> it = _entries;

    // TODO: si tu as des timestamps par entrée, filtre ici selon _period
    // ex: if (_period == _Period.weekly) it = it.where((e) => isInLast7Days(e.date));

    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      it = it.where((e) =>
      e.name.toLowerCase().contains(q) ||
          e.subject.toLowerCase().contains(q) ||
          e.chapter.toLowerCase().contains(q));
    }
    return it.toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return PlayThemedScaffold(
      safeAreaTop: true,
      bodyMode: PlayThemedScaffoldBodyMode.panel,
      // on laisse l'appbar du PlayThemedScaffold pour l'intégration globale
      appBar: AppBar(
        backgroundColor: _brand,
        elevation: 0,
        title: const Text('Classement'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      // padding interne: on met notre header custom, donc padding simple
      bodyPadding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==== Segmented control Hebdo / Tout temps ====
          _SegmentedPeriod(
            value: _period,
            onChanged: (_Period p) => setState(() => _period = p),
            brand: _brand,
          ),
          const SizedBox(height: 16),

          // ==== Barre de recherche ====
          TextField(
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              hintText: 'Chercher (nom / matière / chapitre)',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1F1F22)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
              ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 16),

          // ==== Liste ====
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyState()
                : ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (context, i) {
                final e = filtered[i];
                final rank = i + 1;
                final isFirst = rank == 1;
                final badgeLabel = normalizeArcadeLevel(e.arcadeLevel);

                return _LeaderboardCard(
                  rank: rank,
                  name: e.name,
                  subtitle:
                  'Compétition • ${e.subject.isEmpty ? 'Général' : e.subject}'
                      '${e.chapter.isEmpty ? '' : ' / ${e.chapter}'}',
                  rightTopText: '${e.percent.toStringAsFixed(1)} %',
                  rightBottomText:
                  '${e.correct}/${e.total} • ${_fmtDuration(e.durationSec)}',
                  // Avatar “initiale”
                  avatarText: _initials(e.name),
                  crown: isFirst,
                  badge: badgeLabel,
                  brand: _brand,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDuration(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    if (m == 0) return '${r}s';
    return '${m}m ${r.toString().padLeft(2, '0')}s';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '•';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    final a = parts.first.characters.first.toUpperCase();
    final b = parts.last.characters.first.toUpperCase();
    return '$a$b';
  }
}

// ======================= Widgets UI =======================

class _SegmentedPeriod extends StatelessWidget {
  final _Period value;
  final ValueChanged<_Period> onChanged;
  final Color brand;

  const _SegmentedPeriod({
    required this.value,
    required this.onChanged,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: brand.withOpacity(isDark ? 0.30 : 0.25),
        borderRadius: BorderRadius.circular(22),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final itemW = (w - 8) / 2; // padding interne 4 + 4
          return Stack(
            children: [
              // Track
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _SegmentButton(
                        width: itemW,
                        label: 'Hebdo',
                        selected: value == _Period.weekly,
                        onTap: () => onChanged(_Period.weekly),
                        brand: brand,
                      ),
                      const SizedBox(width: 4),
                      _SegmentButton(
                        width: itemW,
                        label: 'Tout temps',
                        selected: value == _Period.allTime,
                        onTap: () => onChanged(_Period.allTime),
                        brand: brand,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final double width;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color brand;

  const _SegmentButton({
    required this.width,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.0),
          borderRadius: BorderRadius.circular(18),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? brand : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final int rank;
  final String name;
  final String subtitle;
  final String rightTopText;
  final String rightBottomText;
  final String avatarText;
  final bool crown;
  final String badge;
  final Color brand;

  const _LeaderboardCard({
    required this.rank,
    required this.name,
    required this.subtitle,
    required this.rightTopText,
    required this.rightBottomText,
    required this.avatarText,
    required this.crown,
    required this.badge,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final onCard =
    Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(.92) : const Color(0xFF1B1B1F);
    final cardColor =
    Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F1F22) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          // Petit badge rang
          _RankDot(rank: rank),
          const SizedBox(width: 10),

          // Avatar initiale (violet)
          CircleAvatar(
            radius: 22,
            backgroundColor: brand,
            child: Text(
              avatarText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),

          // Nom + chip niveau
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne nom + (crown si 1er)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: onCard,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (crown)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: brand.withOpacity(.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.workspace_premium_outlined, color: brand, size: 18),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Chip niveau + sous-titre
                Row(
                  children: [
                    ArcadeBadgeChip(label: badge, compact: true),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(color: onCard.withOpacity(.7)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Colonne droite (score / détails)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rightTopText, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(rightBottomText, style: TextStyle(color: onCard.withOpacity(.7))),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankDot extends StatelessWidget {
  final int rank;
  const _RankDot({required this.rank});

  @override
  Widget build(BuildContext context) {
    final style = rankDisplayStyleFor(rank);
    // Petit disque clair avec numéro (comme dans la maquette)
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: style.backgroundColor.withOpacity(.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: style.foregroundColor,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.leaderboard_outlined, size: 44, color: Colors.grey),
        const SizedBox(height: 8),
        Text(
          'Aucune entrée pour l’instant',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
