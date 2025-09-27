import 'package:flutter/material.dart';

import '../../../utils/palette_utils.dart';
import '../category_definitions.dart';

class CategoryMenuList extends StatelessWidget {
  final CategoryDefinition definition;
  final ValueChanged<int> onItemSelected;

  const CategoryMenuList({
    super.key,
    required this.definition,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final indexes = definition.itemIndexes;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: indexes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, position) {
        final itemIndex = indexes[position];
        final item = kCategoryMenuItems[itemIndex];
        return _CategoryMenuCard(
          item: item,
          onTap: () => onItemSelected(itemIndex),
        );
      },
    );
  }
}

class _CategoryMenuCard extends StatelessWidget {
  final CategoryMenuItem item;
  final VoidCallback onTap;

  const _CategoryMenuCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = playIconColors(item.palette);
    final theme = Theme.of(context);
    final Color accent = colors.isNotEmpty
        ? colors.last
        : theme.colorScheme.primary;
    final Color background = colors.isNotEmpty
        ? colors.first.withOpacity(0.15)
        : theme.colorScheme.primary.withOpacity(0.08);
    final textStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: background,
            border: Border.all(color: accent.withOpacity(0.35), width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _VisualIcon(item: item, accent: accent),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VisualIcon extends StatelessWidget {
  final CategoryMenuItem item;
  final Color accent;

  const _VisualIcon({
    required this.item,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 64;
    if (item.asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          item.asset!,
          height: size,
          width: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accent.withOpacity(0.15),
      ),
      alignment: Alignment.center,
      child: Icon(item.icon, size: 32, color: accent),
    );
  }
}
