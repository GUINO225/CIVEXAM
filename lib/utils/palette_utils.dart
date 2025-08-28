import 'package:flutter/material.dart';

/// Utilities for design palettes and text contrast
List<Color> paletteFromName(String name) {
  switch (name) {
    case 'coteIvoire':
      // Muted beige echoing Côte d'Ivoire's tones (no gradient)
      return const [Color(0xFFD2B48C)];
    case 'senegal':
      // Subdued olive inspired by Senegal's flag (no gradient)
      return const [Color(0xFF556B2F)];
    case 'ghana':
      // Earthy brown referencing Ghana's colours (no gradient)
      return const [Color(0xFF8B4513)];
    case 'nigeria':
      // Calm sea green reflecting Nigeria's flag (no gradient)
      return const [Color(0xFF2E8B57)];
    case 'kenya':
      // Warm brown hinting at Kenya's palette (no gradient)
      return const [Color(0xFF6B4423)];
    case 'blueAqua':
      return const [Color(0xFF3A4CC5), Color(0xFF6C8BF5)];
    case 'midnight':
      return const [Color(0xFF0F2027), Color(0xFF2C5364)];
    case 'sunset':
      return const [Color(0xFFFF5E62), Color(0xFFFF9966)];
    case 'forest':
      return const [Color(0xFF2F7336), Color(0xFFAAFFA9)];
    case 'ocean':
      return const [Color(0xFF1A2980), Color(0xFF26D0CE)];
    case 'fire':
      return const [Color(0xFFFF512F), Color(0xFFF09819)];
    case 'purple':
      return const [Color(0xFF2A0845), Color(0xFF6441A5)];
    case 'pink':
      return const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)];
    case 'emerald':
      return const [Color(0xFF00B09B), Color(0xFF96C93D)];
    case 'candy':
      return const [Color(0xFFF857A6), Color(0xFFFF5858)];
    case 'steel':
      return const [Color(0xFF232526), Color(0xFF414345)];
    case 'coffee':
      return const [Color(0xFF603813), Color(0xFFB29F94)];
    case 'gold':
      return const [Color(0xFFF6D365), Color(0xFFFDA085)];
    case 'lavender':
      return const [Color(0xFFB993D6), Color(0xFF8CA6DB)];
    case 'blueRoyal':
    default:
      return const [Color(0xFF0D1E42), Color(0xFF37478F)];
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
