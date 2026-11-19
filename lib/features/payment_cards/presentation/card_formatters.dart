import 'package:flutter/services.dart';

import '../../../core/formatters/input_formatters.dart';

/// Groups a card number as `1234 5678 9012 3456` while typing (digits in any
/// script, at most 16).
class CardNumberFormatter extends TextInputFormatter {
  const CardNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = const LatinDigitsFormatter()
        .formatEditUpdate(oldValue, newValue)
        .text
        .replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 16 ? digits.substring(0, 16) : digits;
    final grouped = [
      for (var i = 0; i < capped.length; i += 4)
        capped.substring(i, i + 4 > capped.length ? capped.length : i + 4),
    ].join(' ');
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: grouped.length),
    );
  }
}

/// Types `MM/YY`: the slash appears after the month.
class CardExpiryFormatter extends TextInputFormatter {
  const CardExpiryFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = const LatinDigitsFormatter()
        .formatEditUpdate(oldValue, newValue)
        .text
        .replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 4 ? digits.substring(0, 4) : digits;
    // Deleting the slash must delete the month digit before it too.
    final deleting = newValue.text.length < oldValue.text.length;
    final text = capped.length > 2 || (capped.length == 2 && !deleting)
        ? '${capped.substring(0, 2)}/${capped.substring(2)}'
        : capped;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
