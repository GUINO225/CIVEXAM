/// Design options for the `CompetitionScreen`.
///
/// Centralizes all visual settings so the appearance of the screen can be
/// tweaked in a single place. Each field controls one aspect of the UI and can
/// be modified as needed.
import 'package:flutter/material.dart';

import '../utils/responsive_utils.dart';

@immutable
class CompetitionTheme {
  /// Background color of the whole screen.
  final Color backgroundColor;

  /// Styling for the card that holds the question and progress information.
  final Color questionCardColor;
  /// Optional accent gradient applied behind [questionCardColor].
  final Gradient? questionCardBackgroundGradient;

  /// Text color to use on top of the question card accent.
  final Color questionCardForegroundColor;
  final double questionCardRadius;
  final List<BoxShadow> questionCardShadow;

  /// Styling for the options (answer) cards.
  final Color optionCardColor;
  final double optionCardRadius;
  final List<BoxShadow> optionCardShadow;
  final Color optionSelectedBorderColor;

  /// Color of the progress bar displayed under the question.
  final Color progressBarColor;

  /// Styling for the top app bar and its accents.
  final Color appBarBackgroundColor;
  final Color appBarForegroundColor;
  final Color appBarProgressColor;
  final Color appBarProgressBackgroundColor;

  /// Colors for the information pills displayed in the app bar.
  final Color topPillBackgroundColor;
  final Color topPillForegroundColor;

  /// Dimensions and appearance of the countdown circle.
  final double timerSize;
  final double timerStrokeWidth;
  final Color timerColor;
  final Color timerContainerColor;
  /// Optional accent gradient applied to the timer container.
  final Gradient? timerContainerBackgroundGradient;

  /// Foreground color that keeps the countdown legible on its accent.
  final Color timerOnColor;
  final double timerContainerRadius;
  final List<BoxShadow> timerContainerShadow;

  /// Text styles used throughout the screen.
  final TextStyle timerTextStyle;
  final TextStyle questionIndexTextStyle;
  final TextStyle questionTextStyle;
  final TextStyle optionTextStyle;
  final TextStyle selectedChipTextStyle;

  /// Appearance of the chip that shows the selected answer.
  final Color selectedChipBackgroundColor;
  final double selectedChipRadius;

  const CompetitionTheme({
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.questionCardColor = Colors.white,
    this.questionCardBackgroundGradient,
    this.questionCardForegroundColor = Colors.black,
    this.questionCardRadius = 16.0,
    this.questionCardShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
    ],
    this.optionCardColor = Colors.white,
    this.optionCardRadius = 24.0,
    this.optionCardShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
    ],
    this.optionSelectedBorderColor = Colors.pinkAccent,
    this.progressBarColor = Colors.pinkAccent,
    this.appBarBackgroundColor = const Color(0xFF6C5CE7),
    this.appBarForegroundColor = Colors.white,
    this.appBarProgressColor = Colors.white,
    this.appBarProgressBackgroundColor = const Color(0x40FFFFFF),
    this.topPillBackgroundColor = const Color(0x40FFFFFF),
    this.topPillForegroundColor = Colors.white,
    this.timerSize = 80.0,
    this.timerStrokeWidth = 6.0,
    this.timerColor = Colors.pinkAccent,
    this.timerContainerColor = Colors.white,
    this.timerContainerBackgroundGradient,
    this.timerOnColor = Colors.black,
    this.timerContainerRadius = 12.0,
    this.timerContainerShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
    ],
    this.timerTextStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    this.questionIndexTextStyle = const TextStyle(
      fontSize: 14,
      color: Colors.black54,
    ),
    this.questionTextStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    this.optionTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    this.selectedChipTextStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    this.selectedChipBackgroundColor = Colors.pinkAccent,
    this.selectedChipRadius = 24.0,
  });

  /// Builds a [CompetitionTheme] that matches the global [ThemeData].
  ///
  /// Using the app's color scheme ensures the competition screen adopts the
  /// same visual language as the rest of the interface.
  factory CompetitionTheme.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final Gradient questionCardGradient = LinearGradient(
      colors: [
        scheme.primaryContainer,
        Color.lerp(scheme.primaryContainer, scheme.primary, 0.35)!,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final Gradient timerGradient = LinearGradient(
      colors: [
        scheme.primary,
        Color.lerp(scheme.primary, scheme.primaryContainer, 0.35)!,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return CompetitionTheme(
      backgroundColor: theme.scaffoldBackgroundColor,
      questionCardColor: scheme.primaryContainer,
      questionCardBackgroundGradient: questionCardGradient,
      questionCardForegroundColor: scheme.onPrimaryContainer,
      optionCardColor: theme.cardColor,
      optionSelectedBorderColor: scheme.primary,
      progressBarColor: scheme.primary,
      appBarBackgroundColor: scheme.primary,
      appBarForegroundColor: scheme.onPrimary,
      appBarProgressColor: scheme.onPrimary,
      appBarProgressBackgroundColor: scheme.onPrimary.withOpacity(0.24),
      topPillBackgroundColor: scheme.onPrimary.withOpacity(0.24),
      topPillForegroundColor: scheme.onPrimary,
      timerColor: scheme.primary,
      timerContainerColor: scheme.primary,
      timerContainerBackgroundGradient: timerGradient,
      timerOnColor: scheme.onPrimary,
      timerTextStyle: (textTheme.titleLarge ?? const TextStyle(fontSize: 24)).copyWith(
        fontWeight: FontWeight.bold,
        color: scheme.onPrimary,
      ),
      questionIndexTextStyle:
          (textTheme.bodySmall ?? const TextStyle(fontSize: 14)).copyWith(
        color: scheme.onPrimaryContainer.withOpacity(0.82),
      ),
      questionTextStyle:
          (textTheme.titleMedium ?? const TextStyle(fontSize: 20)).copyWith(
        fontWeight: FontWeight.bold,
        color: scheme.onPrimaryContainer,
      ),
      optionTextStyle: textTheme.bodyMedium ??
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      selectedChipTextStyle: textTheme.bodyMedium?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w600,
          ) ??
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      selectedChipBackgroundColor: scheme.primary,
    );
  }

  /// Returns a responsive copy of this theme using the provided scale factors.
  CompetitionTheme scaled(double scale, TextScaler textScaler) {
    TextStyle scaleText(
      TextStyle style,
      double fallback,
      double min,
      double max,
    ) {
      final baseSize = style.fontSize ?? fallback;
      final fontSize = scaledFontSize(
        base: baseSize,
        scale: scale,
        textScaler: textScaler,
        min: min,
        max: max,
      );
      return style.copyWith(fontSize: fontSize);
    }

    return copyWith(
      questionCardRadius: scaledDimension(
        base: questionCardRadius,
        scale: scale,
        min: 12,
        max: 28,
      ),
      optionCardRadius: scaledDimension(
        base: optionCardRadius,
        scale: scale,
        min: 16,
        max: 32,
      ),
      timerSize: scaledDimension(
        base: timerSize,
        scale: scale,
        min: 56,
        max: 132,
      ),
      timerStrokeWidth: scaledDimension(
        base: timerStrokeWidth,
        scale: scale,
        min: 4,
        max: 9,
      ),
      timerContainerRadius: scaledDimension(
        base: timerContainerRadius,
        scale: scale,
        min: 8,
        max: 20,
      ),
      selectedChipRadius: scaledDimension(
        base: selectedChipRadius,
        scale: scale,
        min: 18,
        max: 32,
      ),
      timerTextStyle: scaleText(timerTextStyle, 24, 18, 36),
      questionIndexTextStyle: scaleText(questionIndexTextStyle, 14, 12, 20),
      questionTextStyle: scaleText(questionTextStyle, 20, 16, 28),
      optionTextStyle: scaleText(optionTextStyle, 16, 14, 24),
      selectedChipTextStyle: scaleText(selectedChipTextStyle, 16, 14, 24),
    );
  }

  /// Creates a copy of this theme with the given fields replaced by new values.
  CompetitionTheme copyWith({
    Color? backgroundColor,
    Color? questionCardColor,
    Gradient? questionCardBackgroundGradient,
    Color? questionCardForegroundColor,
    double? questionCardRadius,
    List<BoxShadow>? questionCardShadow,
    Color? optionCardColor,
    double? optionCardRadius,
    List<BoxShadow>? optionCardShadow,
    Color? optionSelectedBorderColor,
    Color? progressBarColor,
    Color? appBarBackgroundColor,
    Color? appBarForegroundColor,
    Color? appBarProgressColor,
    Color? appBarProgressBackgroundColor,
    Color? topPillBackgroundColor,
    Color? topPillForegroundColor,
    double? timerSize,
    double? timerStrokeWidth,
    Color? timerColor,
    Color? timerContainerColor,
    Gradient? timerContainerBackgroundGradient,
    Color? timerOnColor,
    double? timerContainerRadius,
    List<BoxShadow>? timerContainerShadow,
    TextStyle? timerTextStyle,
    TextStyle? questionIndexTextStyle,
    TextStyle? questionTextStyle,
    TextStyle? optionTextStyle,
    TextStyle? selectedChipTextStyle,
    Color? selectedChipBackgroundColor,
    double? selectedChipRadius,
  }) {
    return CompetitionTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      questionCardColor: questionCardColor ?? this.questionCardColor,
      questionCardBackgroundGradient:
          questionCardBackgroundGradient ?? this.questionCardBackgroundGradient,
      questionCardForegroundColor:
          questionCardForegroundColor ?? this.questionCardForegroundColor,
      questionCardRadius: questionCardRadius ?? this.questionCardRadius,
      questionCardShadow: questionCardShadow ?? this.questionCardShadow,
      optionCardColor: optionCardColor ?? this.optionCardColor,
      optionCardRadius: optionCardRadius ?? this.optionCardRadius,
      optionCardShadow: optionCardShadow ?? this.optionCardShadow,
      optionSelectedBorderColor:
          optionSelectedBorderColor ?? this.optionSelectedBorderColor,
      progressBarColor: progressBarColor ?? this.progressBarColor,
      appBarBackgroundColor:
          appBarBackgroundColor ?? this.appBarBackgroundColor,
      appBarForegroundColor:
          appBarForegroundColor ?? this.appBarForegroundColor,
      appBarProgressColor:
          appBarProgressColor ?? this.appBarProgressColor,
      appBarProgressBackgroundColor: appBarProgressBackgroundColor ??
          this.appBarProgressBackgroundColor,
      topPillBackgroundColor:
          topPillBackgroundColor ?? this.topPillBackgroundColor,
      topPillForegroundColor:
          topPillForegroundColor ?? this.topPillForegroundColor,
      timerSize: timerSize ?? this.timerSize,
      timerStrokeWidth: timerStrokeWidth ?? this.timerStrokeWidth,
      timerColor: timerColor ?? this.timerColor,
      timerContainerColor: timerContainerColor ?? this.timerContainerColor,
      timerContainerBackgroundGradient: timerContainerBackgroundGradient ??
          this.timerContainerBackgroundGradient,
      timerOnColor: timerOnColor ?? this.timerOnColor,
      timerContainerRadius: timerContainerRadius ?? this.timerContainerRadius,
      timerContainerShadow: timerContainerShadow ?? this.timerContainerShadow,
      timerTextStyle: timerTextStyle ?? this.timerTextStyle,
      questionIndexTextStyle:
          questionIndexTextStyle ?? this.questionIndexTextStyle,
      questionTextStyle: questionTextStyle ?? this.questionTextStyle,
      optionTextStyle: optionTextStyle ?? this.optionTextStyle,
      selectedChipTextStyle:
          selectedChipTextStyle ?? this.selectedChipTextStyle,
      selectedChipBackgroundColor:
          selectedChipBackgroundColor ?? this.selectedChipBackgroundColor,
      selectedChipRadius: selectedChipRadius ?? this.selectedChipRadius,
    );
  }
}

/// Default visual settings used by the competition screen.
const CompetitionTheme kDefaultCompetitionTheme = CompetitionTheme();
