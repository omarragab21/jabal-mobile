import 'package:flutter/material.dart';

/// Design tokens taken from the Figma file (Jabal App).
abstract final class AppColors {
  static const Color primary = Color(
    0xFF267B00,
  ); // background/background-primary
  static const Color backgroundBody = Color(
    0xFFF9FAFB,
  ); // background/background-body
  static const Color white = Color(0xFFFFFFFF);
  static const Color neutral200 = Color(
    0xFFEAECF0,
  ); // background/background-neutral-200
  static const Color buttonSecondary = Color(
    0xFFF2F4F7,
  ); // secondary button background
  static const Color textDisplay = Color(0xFF1D2939); // text/text-display
  static const Color textSecondary = Color(
    0xFF667085,
  ); // text/text-secondary-paragraph
  static const Color textDisabled = Color(0xFF98A2B3); // disabled button text
  static const Color textDefault = Color(0xFF161616); // text/text-default
  static const Color textOnColorPrimary = Color(
    0xFFFFFFFF,
  ); // text/text-oncolor-primary

  static const Color border = Color(0xFFD0D5DD); // field border
  static const Color textLabel = Color(0xFF344054); // dial code text
  static const Color error = Color(0xFFE61B1B);
  static const Color success = Color(0xFF1B851B);
  static const Color overlay = Color(0xFF161616); // used at 70% opacity
  static const Color badge = Color(0xFFFF1F1F); // cart count badge

  // Home page
  static const Color newsBar = Color(0xFF087FA8); // news ticker background
  static const Color teal = Color(0xFF005D61); // ask the beauty specialist
  static const Color tealIcon = Color(0xFF7AD5DE);
  static const Color cardBorder = Color(0xFFF2F4F7); // image/tile outline
}
