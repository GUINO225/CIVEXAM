import 'package:flutter/material.dart';
import '../models/design_config.dart';
import '../utils/palette_utils.dart';

/// Builds the global [ThemeData] based on the chosen palette and mode.
ThemeData buildAppTheme(DesignConfig cfg) {
  final iconColors = playIconColors(cfg.bgPaletteName);
  final accent = iconColors.first;
  final complement = complementaryColor(cfg.bgPaletteName);
  final brightness = cfg.darkMode ? Brightness.dark : Brightness.light;
  final textColor =
      textColorForPalette(cfg.bgPaletteName, darkMode: cfg.darkMode);

  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
  );

  final textTheme = base.textTheme
      .apply(bodyColor: textColor, displayColor: textColor)
      .copyWith(
        headlineLarge:
            base.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        headlineMedium:
            base.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        headlineSmall:
            base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge:
            base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.3),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.3),
      );

  return base.copyWith(
    textTheme: textTheme,
    iconTheme: IconThemeData(
      color: iconColors.last,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: complement,
        foregroundColor: onColor(complement),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
      },
    ),
  );
}
