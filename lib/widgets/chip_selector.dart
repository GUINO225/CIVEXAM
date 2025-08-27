import 'package:flutter/material.dart';

class ChipSelector<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final double spacing;
  final double runSpacing;
  final String Function(T)? labelBuilder;

  const ChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.spacing = 8,
    this.runSpacing = 0,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: options.map((o) {
        final isSelected = o == selected;
        return ChoiceChip(
          label: Text(labelBuilder?.call(o) ?? o.toString()),
          selected: isSelected,
          onSelected: (_) => onSelected(o),
        );
      }).toList(),
    );
  }
}
