import '../../../../core/validation/validation_error.dart';
import '../../../../core/validation/validator.dart';

/// Card number: 16 digits that pass the Luhn check.
class CardNumberValidator implements Validator<String> {
  const CardNumberValidator();

  static const int length = 16;

  static String digitsOf(String value) => value.replaceAll(RegExp(r'\D'), '');

  /// The Luhn checksum every real card number satisfies.
  static bool passesLuhn(String digits) {
    var sum = 0;
    var doubled = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var digit = digits.codeUnitAt(i) - 0x30;
      if (doubled) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      doubled = !doubled;
    }
    return sum % 10 == 0;
  }

  @override
  ValidationError? validate(String value) {
    final digits = digitsOf(value);
    if (digits.isEmpty) return const ValidationError(ValidationCode.required);
    if (digits.length != length) {
      return const ValidationError(
        ValidationCode.wrongLength,
        params: {'length': length},
      );
    }
    if (!passesLuhn(digits)) {
      return const ValidationError(ValidationCode.invalidCardNumber);
    }
    return null;
  }
}

/// Expiry `MM/YY`: a real month, and not before the current month.
class CardExpiryValidator implements Validator<String> {
  const CardExpiryValidator({this.now = DateTime.now});

  final DateTime Function() now;

  @override
  ValidationError? validate(String value) {
    final text = value.trim();
    if (text.isEmpty) return const ValidationError(ValidationCode.required);
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(text);
    if (match == null) {
      return const ValidationError(ValidationCode.invalidFormat);
    }
    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    if (month < 1 || month > 12) {
      return const ValidationError(ValidationCode.invalidFormat);
    }
    final today = now();
    final expired =
        year < today.year || (year == today.year && month < today.month);
    return expired ? const ValidationError(ValidationCode.cardExpired) : null;
  }
}

/// Security code: 3 digits.
class CvvValidator implements Validator<String> {
  const CvvValidator();

  static const int length = 3;

  @override
  ValidationError? validate(String value) {
    final text = value.trim();
    if (text.isEmpty) return const ValidationError(ValidationCode.required);
    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return const ValidationError(ValidationCode.invalidCharacters);
    }
    if (text.length != length) {
      return const ValidationError(
        ValidationCode.wrongLength,
        params: {'length': length},
      );
    }
    return null;
  }
}

/// Optional nickname: at most [maxLength] characters.
class CardNicknameValidator implements Validator<String> {
  const CardNicknameValidator({this.maxLength = 20});

  final int maxLength;

  @override
  ValidationError? validate(String value) => value.trim().length > maxLength
      ? ValidationError(ValidationCode.tooLong, params: {'max': maxLength})
      : null;
}
