import 'package:flutter/material.dart';

import '../category_definitions.dart';
import '../category_definitions.dart' as defs show HomeCategory;
import '../../../utils/responsive_utils.dart';
import '../../../utils/rank_display_helper.dart';
import '../../../utils/palette_utils.dart';
import '../../../widgets/arcade_badge_chip.dart';

class CategoryTilesView extends StatelessWidget {
  final CategoryDefinition definition;
  final ValueChanged<int> onItemSelected;
  final Set<int> availableItemIndexes;

  const CategoryTilesView({
    super.key,
    required this.definition,
    required this.onItemSelected,
    this.availableItemIndexes = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final descriptionStyle = theme.textTheme.bodyMedium;
    final helperStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.72),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bool useGrid = width >= 640;
        final indexes = definition.itemIndexes;
        final slivers = <Widget>[
          SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderIcon(accentColor: definition.accentColor, icon: definition.icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(definition.description, style: descriptionStyle),
                      const SizedBox(height: 6),
                      Text('Sélectionnez une carte pour explorer la catégorie.', style: helperStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ];

        if (useGrid) {
          final crossAxisCount = width >= 1040 ? 3 : 2;
          slivers.add(
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, position) {
                  final itemIndex = indexes[position];
                  final item = kCategoryMenuItems[itemIndex];
                  final isAvailable = availableItemIndexes.contains(itemIndex);
                  final rank = _shouldShowRank(definition.category) ? position + 1 : null;
                  final ctaLabel = _ctaLabelFor(definition.category, isAvailable);
                  return _CategoryTileCard(
                    item: item,
                    onTap: () => onItemSelected(itemIndex),
                    isAvailable: isAvailable,
                    rank: rank,
                    ctaLabel: ctaLabel,
                  );
                },
                childCount: indexes.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                mainAxisExtent: 200,
              ),
            ),
          );
        } else {
          final double cardWidth = clampDouble(width * 0.78, 220, 320);
          slivers.add(
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(right: 12),
                  itemCount: indexes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, position) {
                    final itemIndex = indexes[position];
                    final item = kCategoryMenuItems[itemIndex];
                    final isAvailable = availableItemIndexes.contains(itemIndex);
                    final rank = _shouldShowRank(definition.category) ? position + 1 : null;
                    final ctaLabel = _ctaLabelFor(definition.category, isAvailable);
                    return _CategoryTileCard(
                      item: item,
                      onTap: () => onItemSelected(itemIndex),
                      isAvailable: isAvailable,
                      rank: rank,
                      ctaLabel: ctaLabel,
                      width: cardWidth,
                    );
                  },
                ),
              ),
            ),
          );
        }

        slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 12)));
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: slivers,
        );
      },
    );
  }
}

class _CategoryTileCard extends StatelessWidget {
  final CategoryMenuItem item;
  final VoidCallback onTap;
  final bool isAvailable;
  final int? rank;
  final String ctaLabel;
  final double? width;

  const _CategoryTileCard({
    required this.item,
    required this.onTap,
    required this.isAvailable,
    required this.rank,
    required this.ctaLabel,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = item.accentColor;
    final gradient = LinearGradient(
      colors: [accent.withOpacity(0.16), darken(accent, 0.12)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      color: colorScheme.onSurface,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant.withOpacity(0.8),
    );
    final statusText = isAvailable
        ? 'Accès immédiat'
        : 'Disponible prochainement';
    final trailingIcon = isAvailable
        ? Icons.arrow_outward_rounded
        : Icons.lock_clock_rounded;

    Widget card = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: gradient,
            border: Border.all(color: accent.withOpacity(0.28), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TileIcon(item: item, rank: rank),
                const SizedBox(height: 18),
                Text(item.title, style: titleStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Text(statusText, style: subtitleStyle),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ArcadeBadgeChip(label: ctaLabel, compact: true),
                    const Spacer(),
                    Icon(trailingIcon, color: accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (width != null) {
      card = SizedBox(width: width, child: card);
    }

    return card;
  }
}

class _TileIcon extends StatelessWidget {
  final CategoryMenuItem item;
  final int? rank;

  const _TileIcon({required this.item, required this.rank});

  @override
  Widget build(BuildContext context) {
    final accent = item.accentColor;
    final darker = darken(accent, 0.22);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [accent, darker],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.32),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(item.icon, size: 32, color: Colors.white),
        ),
        if (rank != null)
          Positioned(
            top: -10,
            right: -10,
            child: _RankBadge(rank: rank!),
          ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final style = rankDisplayStyleFor(rank);
    return CircleAvatar(
      radius: 14,
      backgroundColor: style.backgroundColor,
      child: style.icon != null
          ? Icon(style.icon, size: 16, color: style.foregroundColor)
          : Text(
              '$rank',
              style: TextStyle(
                color: style.foregroundColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final Color accentColor;
  final IconData icon;

  const _HeaderIcon({required this.accentColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accentColor.withOpacity(0.18),
        border: Border.all(color: accentColor.withOpacity(0.35)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: accentColor, size: 28),
    );
  }
}

bool _shouldShowRank(defs.HomeCategory category) {
  switch (category) {
    case defs.HomeCategory.challenge:
    case defs.HomeCategory.history:
      return true;
    default:
      return false;
  }
}

String _ctaLabelFor(defs.HomeCategory category, bool isAvailable) {
  if (!isAvailable) {
    return 'Bientôt';
  }
  switch (category) {
    case defs.HomeCategory.quickPrep:
      return 'Lancer';
    case defs.HomeCategory.courses:
      return 'Ouvrir';
    case defs.HomeCategory.bank:
      return 'Explorer';
    case defs.HomeCategory.resources:
      return 'Consulter';
    case defs.HomeCategory.history:
      return 'Voir';
    case defs.HomeCategory.challenge:
      return 'Jouer';
    case defs.HomeCategory.help:
      return 'Lire';
  }
}
