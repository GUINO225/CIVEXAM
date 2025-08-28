import 'package:flutter/material.dart';

/// Utilities for design palettes and text contrast
List<Color> paletteFromName(String name) {
  switch (name) {
    case 'red':
      return const [Color(0xFFD32F2F), Color(0xFFF44336)];
    case 'orange':
      return const [Color(0xFFF57C00), Color(0xFFFF9800)];
    case 'yellow':
      return const [Color(0xFFFBC02D), Color(0xFFFFEB3B)];
    case 'green':
      return const [Color(0xFF388E3C), Color(0xFF66BB6A)];
    case 'blue':
      return const [Color(0xFF1976D2), Color(0xFF42A5F5)];
    case 'indigo':
      return const [Color(0xFF303F9F), Color(0xFF5C6BC0)];
    case 'violet':
      return const [Color(0xFF8E24AA), Color(0xFFAB47BC)];
    default:
      // Fallback to blue palette if name is unknown
      return const [Color(0xFF1976D2), Color(0xFF42A5F5)];
  }
}

/// Returns [Colors.white] or [Colors.black] depending on the average
/// brightness of the palette.
Color textColorForPalette(String name) {
  final colors = paletteFromName(name);
  // Average the palette colors
  int r = 0, g = 0, b = 0;
  for (final c in colors) {
    r += c.red;
    g += c.green;
    b += c.blue;
  }
  final avg = Color.fromARGB(255, r ~/ colors.length, g ~/ colors.length, b ~/ colors.length);
  final brightness = ThemeData.estimateBrightnessForColor(avg);
  return brightness == Brightness.dark ? Colors.white : Colors.black;
}
