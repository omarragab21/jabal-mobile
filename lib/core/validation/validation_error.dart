import 'package:equatable/equatable.dart';

/// Machine-readable reason why a value is invalid. The UI maps each code to a
/// localized message (`validation.<field>.<code>` or `validation.<code>`).
enum ValidationCode {
  required,
  tooShort,
  tooLong,
  invalidCharacters,
  invalidFormat,
  hasWhitespace,
  repeatedCharacters,
  noUppercase,
  noLowercase,
  noDigit,
  noSpecialChar,
  commonPassword,
  sequentialCharacters,
  containsPersonalInfo,
  invalidPhone,
  notMobileNumber,
  wrongLength,
  invalidCardNumber,
  cardExpired,
}

class ValidationError extends Equatable {
  const ValidationError(this.code, {this.params = const {}});

  final ValidationCode code;

  /// Values for message placeholders, e.g. `{min: 8}` -> "{min}".
  final Map<String, Object> params;

  @override
  List<Object?> get props => [code, params];

  @override
  String toString() => 'ValidationError($code, $params)';
}
