import 'package:flutter/services.dart';

import '../../features/auth/domain/validators/digit_normalizer.dart';

/// Converts Arabic-Indic / Persian digits to 0-9 while typing or pasting.
class LatinDigitsFormatter extends TextInputFormatter {
  const LatinDigitsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final converted = DigitNormalizer.toLatin(newValue.text);
    return converted == newValue.text
        ? newValue
        : newValue.copyWith(text: converted);
  }
}

/// Phone/OTP typing: any digit script in, Latin digits out, capped at [max].
List<TextInputFormatter> digitsFormatters({int? max}) => [
  const LatinDigitsFormatter(),
  FilteringTextInputFormatter.digitsOnly,
  if (max != null) LengthLimitingTextInputFormatter(max),
];

/// Blocks spaces (emails, passwords) and caps the length.
List<TextInputFormatter> noSpaceFormatters({required int max}) => [
  FilteringTextInputFormatter.deny(RegExp(r'\s')),
  LengthLimitingTextInputFormatter(max),
];
