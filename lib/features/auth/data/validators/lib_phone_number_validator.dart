import 'package:phone_numbers_parser/phone_numbers_parser.dart' as lib;

import '../../../../core/validation/validation_error.dart';
import '../../domain/entities/phone_number.dart';
import '../../domain/validators/digit_normalizer.dart';
import '../../domain/validators/phone_number_validator.dart';

/// Validates with Google's libphonenumber metadata (offline, via
/// `phone_numbers_parser`): the number must match the country's numbering
/// plan AND be a mobile number (the code is sent by SMS).
class LibPhoneNumberValidator implements PhoneNumberValidator {
  const LibPhoneNumberValidator();

  @override
  ValidationError? validate(PhoneNumber phone) {
    final digits = DigitNormalizer.digitsOnly(phone.national);
    if (digits.isEmpty) return const ValidationError(ValidationCode.required);

    final iso = lib.IsoCode.values
        .where((c) => c.name == phone.isoCode.toUpperCase())
        .firstOrNull;
    if (iso == null) return const ValidationError(ValidationCode.invalidPhone);

    try {
      final parsed = lib.PhoneNumber.parse(digits, destinationCountry: iso);
      if (!parsed.isValid()) {
        return const ValidationError(ValidationCode.invalidPhone);
      }
      if (!parsed.isValid(type: lib.PhoneNumberType.mobile)) {
        return const ValidationError(ValidationCode.notMobileNumber);
      }
      return null;
    } catch (_) {
      return const ValidationError(ValidationCode.invalidPhone);
    }
  }
}
