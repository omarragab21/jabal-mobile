import '../../../../core/validation/string_rules.dart';
import '../../../../core/validation/validation_error.dart';
import '../../../../core/validation/validator.dart';

/// Full name: 2–50 characters, letters (any language) with single spaces,
/// apostrophes, dots and hyphens; no digits/symbols and no `aaa` runs.
class NameValidator implements Validator<String> {
  NameValidator({this.minLength = 2, this.maxLength = 50}) {
    _rules = CompositeValidator<String>([
      const RequiredRule(),
      MinLengthRule(minLength),
      MaxLengthRule(maxLength),
      MatchesRule(
        RegExp(
          r"^[\p{L}\p{M}]+(?:(?:\. |[ '\-])[\p{L}\p{M}]+)*\.?$",
          unicode: true,
        ),
        ValidationCode.invalidCharacters,
      ),
      MustNotContainRule(
        RegExp(r'(.)\1{2,}', unicode: true),
        ValidationCode.repeatedCharacters,
      ),
    ]);
  }

  final int minLength;
  final int maxLength;
  late final CompositeValidator<String> _rules;

  /// Trimmed, inner spaces collapsed.
  static String normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  @override
  ValidationError? validate(String value) => _rules.validate(normalize(value));
}
