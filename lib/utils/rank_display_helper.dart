import 'package:flutter/material.dart';

class RankDisplayStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;

  const RankDisplayStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
  });
}

const Color _kGoldColor = Color(0xFFFFD700);
const Color _kSilverColor = Color(0xFFC0C0C0);
const Color _kBronzeColor = Color(0xFFCD7F32);
const Color _kDefaultBackground = Color(0xFFCFD8DC);
const Color _kDefaultForeground = Color(0xDD000000);

RankDisplayStyle rankDisplayStyleFor(int rank) {
  switch (rank) {
    case 1:
      return const RankDisplayStyle(
        backgroundColor: _kGoldColor,
        foregroundColor: _kDefaultForeground,
        icon: Icons.emoji_events,
      );
    case 2:
      return const RankDisplayStyle(
        backgroundColor: _kSilverColor,
        foregroundColor: _kDefaultForeground,
        icon: Icons.emoji_events,
      );
    case 3:
      return const RankDisplayStyle(
        backgroundColor: _kBronzeColor,
        foregroundColor: _kDefaultForeground,
        icon: Icons.emoji_events,
      );
    default:
      return const RankDisplayStyle(
        backgroundColor: _kDefaultBackground,
        foregroundColor: _kDefaultForeground,
      );
  }
}
