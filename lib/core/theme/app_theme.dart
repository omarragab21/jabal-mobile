import 'package:flutter/material.dart';

import 'app_fonts.dart';
import 'app_text_theme.dart';

abstract final class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.family,
    textTheme: AppTextTheme.textTheme,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  );
}
