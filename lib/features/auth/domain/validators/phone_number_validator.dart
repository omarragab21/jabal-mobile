import '../../../../core/validation/validation_error.dart';
import '../entities/phone_number.dart';

/// Validates that [phone] is a real *mobile* number of its country.
/// The implementation is injected, so the rule source (offline metadata,
/// a server lookup…) can change without touching the cubits.
abstract interface class PhoneNumberValidator {
  ValidationError? validate(PhoneNumber phone);
}
