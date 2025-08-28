import 'package:flutter/material.dart';

/// Utilities for design palettes and contrast helpers
Color accentColor(String name) {
  switch (name) {
    case 'red':
      return const Color(0xFFE53935);
    case 'orange':
      return const Color(0xFFFB8C00);
    case 'yellow':
      return const Color(0xFFFDD835);
    case 'green':
      return const Color(0xFF43A047);
    case 'blue':
      return const Color(0xFF1E88E5);
    case 'indigo':
      return const Color(0xFF3949AB);
    case 'violet':
      return const Color(0xFF8E24AA);
    default:
      return const Color(0xFF1E88E5);
  }
}

/// Returns two pastel variants of the accent color for gradient backgrounds.
List<Color> pastelColors(String name, {bool darkMode = false}) {
  final accent = accentColor(name);
  final hsl = HSLColor.fromColor(accent);
  final light1 = darkMode ? 0.25 : 0.85;
  final light2 = darkMode ? 0.35 : 0.95;
  final c1 = hsl.withLightness(light1).toColor();
  final c2 = hsl.withLightness(light2).toColor();
  return [c1, c2];
}

/// Complementary color used for buttons to stand out from the background.
Color complementaryColor(String name) {
  final accent = accentColor(name);
  final hsl = HSLColor.fromColor(accent);
  return hsl.withHue((hsl.hue + 180.0) % 360).toColor();
}

/// Returns [Colors.white] or [Colors.black] depending on the background brightness.
Color textColorForPalette(String name, {bool darkMode = false}) {
  final colors = pastelColors(name, darkMode: darkMode);
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

/// Helper to get readable text color on top of any solid [color].
Color onColor(Color color) =>
    ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
