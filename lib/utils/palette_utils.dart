import 'package:flutter/material.dart';

/// Utilities for design palettes and contrast helpers
Color accentColor(String name) {
  switch (name) {
    case 'offWhite':
      return const Color(0xFFF5F5F5);
    case 'lightGrey':
      return const Color(0xFFEAEAEA);
    case 'darkGrey':
      return const Color(0xFF2C2C2C);
    case 'pastelBlue':
      return const Color(0xFFA8DADC);
    case 'powderPink':
      return const Color(0xFFF7CAD0);
    case 'lightGreen':
      return const Color(0xFFB7E4C7);
    case 'softYellow':
      return const Color(0xFFFFE66D);
    case 'midnightBlue':
      return const Color(0xFF1E1E2F);
    case 'anthracite':
      return const Color(0xFF2B2B2B);
    case 'blueIndigo':
      return const Color(0xFF2193B0);
    case 'violetRose':
      return const Color(0xFF7F00FF);
    case 'mintTurquoise':
      return const Color(0xFF43CEA2);
    case 'deepBlack':
      return const Color(0xFF121212);
    case 'sereneBlue':
      return const Color(0xFF1A73E8);
    case 'forestGreen':
      return const Color(0xFF2E7D32);
    case 'deepIndigo':
      return const Color(0xFF283593);
    case 'royalViolet':
      return const Color(0xFF6A1B9A);
    case 'navyCyanAmber':
      return const Color(0xFF1E3A8A); // Primary
    case 'indigoPurpleSky':
      return const Color(0xFF4F46E5); // Primary
    case 'emeraldTealMint':
      return const Color(0xFF059669); // Primary
    case 'royalBlueGold':
      return const Color(0xFF37478F); // Primary
    case 'charcoalElectric':
      return const Color(0xFF3B82F6); // Primary
    case 'forestSandTerracotta':
      return const Color(0xFF1B5E20); // Primary
    case 'cobaltLimeSlate':
      return const Color(0xFF2563EB); // Primary
    case 'calmPastels':
      return const Color(0xFF8FA6FF); // Primary
    default:
      return const Color(0xFFF5F5F5);
  }
}

/// Darkens a [Color] by decreasing its lightness in HSL space.
Color darken(Color color, [double amount = 0.1]) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}

/// Returns a darker variant of the palette's accent color.
Color darkerAccentColor(String name, [double amount = 0.2]) =>
    darken(accentColor(name), amount);

/// Gradient colors used for PlayScreen icons based on the active palette.
///
/// Returns a pair of colors where the first color should match the
/// [accentColor] for the palette so that the UI theme and the play icons share
/// the same hue. If the [paletteName] is unknown, it falls back to the original
/// PlayScreen gradient.
List<Color> playIconColors(String paletteName) {
  const fallback = [Color(0xFFFFB25E), Color(0xFFFF7A00)];
  final accent = accentColor(paletteName);

  // If the palette name is not recognized, accentColor returns the offWhite
  // color. In that case, preserve the legacy gradient from the PlayScreen.
  if (accent.value == const Color(0xFFF5F5F5).value && paletteName != 'offWhite') {
    return fallback;
  }

  return [accent, darkerAccentColor(paletteName)];
}

/// Returns two pastel variants of the accent color for gradient backgrounds.
List<Color> pastelColors(String name, {bool darkMode = false}) {
  switch (name) {
    case 'offWhite':
      return const [Color(0xFFF5F5F5), Color(0xFFF5F5F5)];
    case 'lightGrey':
      return const [Color(0xFFEAEAEA), Color(0xFFEAEAEA)];
    case 'darkGrey':
      return const [Color(0xFF2C2C2C), Color(0xFF2C2C2C)];
    case 'pastelBlue':
      return const [Color(0xFFA8DADC), Color(0xFFA8DADC)];
    case 'powderPink':
      return const [Color(0xFFF7CAD0), Color(0xFFF7CAD0)];
    case 'lightGreen':
      return const [Color(0xFFB7E4C7), Color(0xFFB7E4C7)];
    case 'softYellow':
      return const [Color(0xFFFFE66D), Color(0xFFFFE66D)];
    case 'midnightBlue':
      return const [Color(0xFF1E1E2F), Color(0xFF1E1E2F)];
    case 'anthracite':
      return const [Color(0xFF2B2B2B), Color(0xFF2B2B2B)];
    case 'blueIndigo':
      return const [Color(0xFF2193B0), Color(0xFF6DD5ED)];
    case 'violetRose':
      return const [Color(0xFF7F00FF), Color(0xFFE100FF)];
    case 'mintTurquoise':
      return const [Color(0xFF43CEA2), Color(0xFF185A9D)];
    case 'deepBlack':
      return const [Color(0xFF121212), Color(0xFF121212)];
    case 'sereneBlue':
      return const [Color(0xFF1A73E8), Color(0xFF64B5F6)];
    case 'forestGreen':
      return const [Color(0xFF2E7D32), Color(0xFF81C784)];
    case 'deepIndigo':
      return const [Color(0xFF283593), Color(0xFF5C6BC0)];
    case 'royalViolet':
      return const [Color(0xFF6A1B9A), Color(0xFFBA68C8)];
    case 'navyCyanAmber':
      return const [Color(0xFFF8FAFC), Color(0xFFFFFFFF)];
    case 'indigoPurpleSky':
      return const [Color(0xFFF5F3FF), Color(0xFFFFFFFF)];
    case 'emeraldTealMint':
      return const [Color(0xFFF0FDF4), Color(0xFFFFFFFF)];
    case 'royalBlueGold':
      return const [Color(0xFFFFFFFF), Color(0xFFF6F8FF)];
    case 'charcoalElectric':
      return const [Color(0xFF0B1220), Color(0xFF0F172A)];
    case 'forestSandTerracotta':
      return const [Color(0xFFFFF8F1), Color(0xFFFFFFFF)];
    case 'cobaltLimeSlate':
      return const [Color(0xFFF8FAFC), Color(0xFFFFFFFF)];
    case 'calmPastels':
      return const [Color(0xFFF7F7FB), Color(0xFFFFFFFF)];
    default:
      final accent = accentColor(name);
      final hsl = HSLColor.fromColor(accent);
      final light1 = darkMode ? 0.25 : 0.85;
      final light2 = darkMode ? 0.35 : 0.95;
      final c1 = hsl.withLightness(light1).toColor();
      final c2 = hsl.withLightness(light2).toColor();
      return [c1, c2];
  }
}

/// Complementary color used for buttons to stand out from the background.
Color complementaryColor(String name) {
  switch (name) {
    case 'navyCyanAmber':
      return const Color(0xFFF59E0B); // Accent
    case 'indigoPurpleSky':
      return const Color(0xFF38BDF8); // Accent
    case 'emeraldTealMint':
      return const Color(0xFF2DD4BF); // Accent
    case 'royalBlueGold':
      return const Color(0xFF00B3C6); // Accent
    case 'charcoalElectric':
      return const Color(0xFFF472B6); // Accent
    case 'forestSandTerracotta':
      return const Color(0xFFD4A373); // Accent
    case 'cobaltLimeSlate':
      return const Color(0xFF64748B); // Accent
    case 'calmPastels':
      return const Color(0xFFB7E4C7); // Accent
    default:
      final accent = accentColor(name);
      final hsl = HSLColor.fromColor(accent);
      return hsl.withHue((hsl.hue + 180.0) % 360).toColor();
  }
}

/// Returns [Colors.white] or [Colors.black] depending on the background brightness.
Color textColorForPalette(String name, {bool darkMode = false}) {
  switch (name) {
    case 'navyCyanAmber':
      return const Color(0xFF0F172A);
    case 'indigoPurpleSky':
      return const Color(0xFF111827);
    case 'emeraldTealMint':
      return const Color(0xFF0F172A);
    case 'royalBlueGold':
      return const Color(0xFF0F172A);
    case 'charcoalElectric':
      return const Color(0xFFE5E7EB);
    case 'forestSandTerracotta':
      return const Color(0xFF1F2937);
    case 'cobaltLimeSlate':
      return const Color(0xFF0F172A);
    case 'calmPastels':
      return const Color(0xFF1F2937);
    default:
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
}

/// Helper to get readable text color on top of any solid [color].
Color onColor(Color color) =>
    ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
