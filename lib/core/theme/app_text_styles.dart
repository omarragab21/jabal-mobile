import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_fonts.dart';

/// Text styles from the Figma file. `height` = lineHeight / fontSize.
abstract final class AppTextStyles {
  /// Display sm/Bold — 30 / 38
  static TextStyle get displaySmBold => TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 30.sp,
    height: 38 / 30,
    fontWeight: AppFonts.bold,
  );

  /// Display xs/Semibold — 24 / 32
  static TextStyle get displayXsBold => TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 24.sp,
    height: 32 / 24,
    fontWeight: AppFonts.bold,
  );

  /// Text md/Regular — 16 / 24
  static TextStyle get textMdRegular => TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 16.sp,
    height: 24 / 16,
    fontWeight: AppFonts.regular,
  );

  /// Text sm/Regular — 14 / 20
  static TextStyle get textSmRegular => TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 14.sp,
    height: 20 / 14,
    fontWeight: AppFonts.regular,
  );

  /// Text xs/Regular — 12 / 18
  static TextStyle get textXsRegular => TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 12.sp,
    height: 18 / 12,
    fontWeight: AppFonts.regular,
  );

  /// Text lg/Bold — 18 / 28 (screen titles)
  static TextStyle get textLgBold => TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 18.sp,
    height: 28 / 18,
    fontWeight: AppFonts.bold,
  );

  /// Text md/Bold — 16 / 24
  static TextStyle get textMdBold => TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 16.sp,
    height: 24 / 16,
    fontWeight: AppFonts.bold,
  );

  /// Text sm/Bold — 14 / 20
  static TextStyle get textSmBold => TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 14.sp,
    height: 20 / 14,
    fontWeight: AppFonts.bold,
  );

  /// Text xs/Bold — 12 / 18
  static TextStyle get textXsBold => TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 12.sp,
    height: 18 / 12,
    fontWeight: AppFonts.bold,
  );
}
