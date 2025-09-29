import 'package:flutter/material.dart';

class CalendarOverlayConfig {
  final bool showSeconds;
  final bool use24h;
  final EdgeInsets padding;
  final double borderRadius;
  final Color bgColor;
  final Color iconColor;
  final double iconSize;
  final TextStyle textStyle;
  final double spacing;
  final List<BoxShadow>? shadows;

  const CalendarOverlayConfig({
    this.showSeconds = false,
    this.use24h = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.borderRadius = 16,
    this.bgColor = const Color(0xFF2E53B3),
    this.iconColor = const Color(0xFFFFD740),
    this.iconSize = 24,
    this.textStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    this.spacing = 10,
    this.shadows = const [
      BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  });
}

const CalendarOverlayConfig defaultCalendarOverlayConfig =
    CalendarOverlayConfig();
