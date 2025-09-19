import 'package:flutter/widgets.dart';

/// Computes a UI scale factor based on the device's shortest side.
///
/// The layout was originally designed for phones around 390 px wide. We
/// normalize the current shortest side against that baseline and clamp the
/// result so very small or very large devices remain readable.
double computeScaleFactor(
  MediaQueryData mediaQuery, {
  double baseWidth = 390,
  double minScale = 0.85,
  double maxScale = 1.25,
}) {
  final shortestSide = mediaQuery.size.shortestSide;
  if (shortestSide <= 0) {
    return 1.0;
  }
  final raw = shortestSide / baseWidth;
  final clamped = raw.clamp(minScale, maxScale);
  return clamped is double ? clamped : clamped.toDouble();
}

/// Clamps [value] between [min] and [max] and returns a double.
double clampDouble(num value, double min, double max) {
  final clamped = value.clamp(min, max);
  return clamped is double ? clamped : clamped.toDouble();
}

/// Computes a responsive font size using the provided [scale] and [textScaler].
///
/// The [base] size corresponds to the design baseline. Optional [min] and
/// [max] bounds keep the resulting value within a comfortable range.
double scaledFontSize({
  required double base,
  required double scale,
  required TextScaler textScaler,
  double? min,
  double? max,
}) {
  final scaled = textScaler.scale(base * scale);
  if (min != null || max != null) {
    return clampDouble(
      scaled,
      min ?? scaled,
      max ?? scaled,
    );
  }
  return scaled;
}

/// Scales a non-text dimension (icons, radii, etc.) while keeping it bounded.
double scaledDimension({
  required double base,
  required double scale,
  double? min,
  double? max,
}) {
  final value = base * scale;
  if (min != null || max != null) {
    return clampDouble(
      value,
      min ?? value,
      max ?? value,
    );
  }
  return value;
}
