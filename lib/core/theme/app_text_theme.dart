import 'package:flutter/material.dart';

import 'app_fonts.dart';

/// Typography scale using Almarai. Sizes follow Material 3; weights are
/// limited to those Almarai ships (300/400/700/800).
abstract final class AppTextTheme {
  static TextTheme get textTheme => const TextTheme(
    displayLarge: _Style(57, AppFonts.regular),
    displayMedium: _Style(45, AppFonts.regular),
    displaySmall: _Style(36, AppFonts.regular),
    headlineLarge: _Style(32, AppFonts.extraBold),
    headlineMedium: _Style(28, AppFonts.extraBold),
    headlineSmall: _Style(24, AppFonts.bold),
    titleLarge: _Style(22, AppFonts.bold),
    titleMedium: _Style(16, AppFonts.bold),
    titleSmall: _Style(14, AppFonts.bold),
    bodyLarge: _Style(16, AppFonts.regular),
    bodyMedium: _Style(14, AppFonts.regular),
    bodySmall: _Style(12, AppFonts.light),
    labelLarge: _Style(14, AppFonts.bold),
    labelMedium: _Style(12, AppFonts.bold),
    labelSmall: _Style(11, AppFonts.regular),
  );
}

class _Style extends TextStyle {
  const _Style(double size, FontWeight weight)
    : super(fontFamily: AppFonts.family, fontSize: size, fontWeight: weight);
}
