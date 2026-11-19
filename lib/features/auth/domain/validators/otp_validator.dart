import '../../../../core/validation/string_rules.dart';
import '../../../../core/validation/validation_error.dart';
import '../../../../core/validation/validator.dart';
import 'digit_normalizer.dart';

/// Verification code: exactly [length] digits.
class OtpValidator implements Validator<String> {
  OtpValidator({this.length = 4}) {
    _rules = CompositeValidator<String>([
      const RequiredRule(),
      MatchesRule(RegExp(r'^[0-9]+$'), ValidationCode.invalidCharacters),
      ExactLengthRule(length),
    ]);
  }

  final int length;
  late final CompositeValidator<String> _rules;

  @override
  ValidationError? validate(String value) =>
      _rules.validate(DigitNormalizer.toLatin(value).trim());
}
