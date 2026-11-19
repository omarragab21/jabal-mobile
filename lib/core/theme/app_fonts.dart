import 'package:flutter/material.dart';

/// Almarai font family, declared in pubspec.yaml.
/// Available weights: Light (300), Regular (400), Bold (700), ExtraBold (800).
abstract final class AppFonts {
  static const String family = 'Almarai';

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}
