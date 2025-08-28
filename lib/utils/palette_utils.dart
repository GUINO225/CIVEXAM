import 'package:flutter/material.dart';

/// Utilities for design palettes and text contrast
List<Color> paletteFromName(String name) {
  switch (name) {
    case 'midnight':
      // Soft steel blue toward deep navy
      return const [Color(0xFFB0C4DE), Color(0xFF2C5364)];
    case 'forest':
      // Gentle green center fading to dark forest edge
      return const [Color(0xFFDDEED7), Color(0xFF2F7336)];
    case 'ocean':
      // Pale aqua center to deep ocean blue
      return const [Color(0xFFD7F2F3), Color(0xFF1A2980)];
    case 'purple':
      // Light lavender center to rich purple edge
      return const [Color(0xFFE6DAF5), Color(0xFF2A0845)];
    case 'lavender':
      // Almost white lavender to muted periwinkle
      return const [Color(0xFFF2ECFF), Color(0xFF8CA6DB)];
    case 'steel':
      // Soft grey center to charcoal edge
      return const [Color(0xFFE5E7EA), Color(0xFF414345)];
    case 'coffee':
      // Creamy center to dark coffee edge
      return const [Color(0xFFEAD7C4), Color(0xFF603813)];
    case 'fireOcean':
      // Fire Ocean palette
      return const [
        Color(0xFF780000),
        Color(0xFFC1121F),
        Color(0xFFFDF0D5),
        Color(0xFF003049),
        Color(0xFF669BBC),
      ];
    case 'refreshingSummer':
      return const [
        Color(0xFF8ECAE6),
        Color(0xFF219EBC),
        Color(0xFF023047),
        Color(0xFFFFB703),
        Color(0xFFFB8500),
      ];
    case 'oliveGardenFeast':
      return const [
        Color(0xFF606C38),
        Color(0xFF283618),
        Color(0xFFFEFAE0),
        Color(0xFFDDA15E),
        Color(0xFFBC6C25),
      ];
    case 'oceanBleuSerenity':
      return const [
        Color(0xFF03045E),
        Color(0xFF023E8A),
        Color(0xFF0077B6),
        Color(0xFF0096C7),
        Color(0xFF00B4D8),
        Color(0xFF48CAE4),
        Color(0xFF90E0EF),
        Color(0xFFADE8F4),
        Color(0xFFCAF0F8),
      ];
    case 'softPink':
      return const [
        Color(0xFFFFE5EC),
        Color(0xFFFFC2D1),
        Color(0xFFFFB3C6),
        Color(0xFFFF8FAB),
        Color(0xFFFB6F92),
      ];
    case 'oceanBreeze':
      return const [
        Color(0xFF03045E),
        Color(0xFF0077B6),
        Color(0xFF00B4D8),
        Color(0xFF90E0EF),
        Color(0xFFCAF0F8),
      ];
    case 'softSand':
      return const [
        Color(0xFFEDEDE9),
        Color(0xFFD6CCC2),
        Color(0xFFF5EBE0),
        Color(0xFFE3D5CA),
        Color(0xFFD5BDAF),
      ];
    case 'beachSunset':
      return const [
        Color(0xFFBEE9E8),
        Color(0xFF62B6CB),
        Color(0xFF1B4965),
        Color(0xFFCAE9FF),
        Color(0xFF5FA8D3),
      ];
    case 'slateGrayContrast':
      return const [
        Color(0xFFFF6700),
        Color(0xFFEBEBEB),
        Color(0xFFC0C0C0),
        Color(0xFF3A6EA5),
        Color(0xFF004E98),
      ];
    case 'blueRoyal':
    default:
      // Subtle light blue center to royal blue edge
      return const [Color(0xFFE1E6F2), Color(0xFF0D1E42)];
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
