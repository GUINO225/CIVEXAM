import 'package:characters/characters.dart';
import 'package:flutter/material.dart';

import '../models/calendar_overlay_config.dart';
import '../models/leaderboard_entry.dart';
import '../services/arcade_progress_store.dart';
import '../utils/rank_display_helper.dart';
import 'arcade_badge_chip.dart';

class PlayGreetingHeader extends StatelessWidget {
  const PlayGreetingHeader({
    super.key,
    required this.topInset,
    required this.hasName,
    required this.name,
    required this.profileNickname,
    required this.welcomeFontSize,
    required this.nameFontSize,
    required this.arcadeProgress,
    required this.arcadeProgressLoading,
    required this.leaderboardEntry,
    required this.rank,
    required this.now,
    required this.calendarConfig,
  });

  static const double _baseHeight = 150;

  static double heightFor(double topInset) => topInset + _baseHeight;

  final double topInset;
  final bool hasName;
  final String? name;
  final String? profileNickname;
  final double welcomeFontSize;
  final double nameFontSize;
  final ArcadeProgressData? arcadeProgress;
  final bool arcadeProgressLoading;
  final LeaderboardEntry? leaderboardEntry;
  final int? rank;
  final DateTime now;
  final CalendarOverlayConfig calendarConfig;

  @override
  Widget build(BuildContext context) {
    final trimmedProfileNickname = profileNickname?.trim();
    final entryName = leaderboardEntry?.name.trim();
    final leaderboardName =
        entryName != null && entryName.isNotEmpty ? entryName : null;
    final userName = hasName && (name?.trim().isNotEmpty ?? false)
        ? name!.trim()
        : null;
    final displayName = (trimmedProfileNickname != null &&
            trimmedProfileNickname.isNotEmpty)
        ? trimmedProfileNickname
        : (leaderboardName ?? userName ?? 'Utilisateur');
    final avatarLabel = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : '?';

    final greeting = now.hour < 18 ? 'Bonjour' : 'Bonsoir';
    final icon = (now.hour >= 6 && now.hour < 18)
        ? Icons.wb_sunny_rounded
        : Icons.nights_stay_rounded;
    final formattedDate = _formatDateTime(now);
    final RankDisplayStyle? rankStyle =
        rank != null ? rankDisplayStyleFor(rank!) : null;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, topInset + 24, 24, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF6C4DFF),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    greeting,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: welcomeFontSize,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (arcadeProgressLoading)
                        const SizedBox(
                          height: 28,
                          width: 28,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      else if (arcadeProgress != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ArcadeBadgeChip(
                            label: arcadeProgress!.levelLabel,
                            compact: true,
                          ),
                        ),
                      Flexible(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: rankStyle?.backgroundColor ?? Colors.white,
                child: rank != null && rankStyle != null
                    ? Text(
                        '$rank',
                        style: TextStyle(
                          color: rankStyle.foregroundColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      )
                    : Text(
                        avatarLabel,
                        style: const TextStyle(
                          color: Color(0xFF6C4DFF),
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    final y = value.year.toString();
    final m = two(value.month);
    final d = two(value.day);
    int hour = value.hour;
    String suffix = '';
    if (!calendarConfig.use24h) {
      suffix = hour >= 12 ? ' PM' : ' AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
    }
    final h = two(hour);
    final min = two(value.minute);
    final sec = two(value.second);
    final time = calendarConfig.showSeconds ? '$h:$min:$sec' : '$h:$min';
    return '$d/$m/$y  $time$suffix';
  }
}
