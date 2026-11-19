import '../../../../core/validation/string_rules.dart';
import '../../../../core/validation/validation_error.dart';
import '../../../../core/validation/validator.dart';
import 'common_passwords.dart';

enum PasswordStrength { weak, medium, strong }

/// Strong-password policy used at sign-up (login only checks "not empty").
///
/// Rules: 8–64 chars, no spaces, upper + lower case, a digit and a symbol,
/// not a common password, no ascending/descending runs (`abcd`, `4321`), no
/// repeated characters (`aaa`), and nothing derived from the user's own data
/// (name parts, email, phone) passed in [personalData].
class PasswordValidator implements Validator<String> {
  PasswordValidator({
    this.minLength = 8,
    this.maxLength = 64,
    this.personalData = const [],
  }) {
    _rules = CompositeValidator<String>([
      const RequiredRule(),
      MinLengthRule(minLength),
      MaxLengthRule(maxLength),
      MustNotContainRule(RegExp(r'\s'), ValidationCode.hasWhitespace),
      MatchesRule(RegExp(r'[A-Z]'), ValidationCode.noUppercase),
      MatchesRule(RegExp(r'[a-z]'), ValidationCode.noLowercase),
      MatchesRule(RegExp(r'[0-9]'), ValidationCode.noDigit),
      MatchesRule(RegExp(r'[^A-Za-z0-9]'), ValidationCode.noSpecialChar),
      PredicateRule<String>(
        (v) => !_containsPersonal(v),
        ValidationCode.containsPersonalInfo,
      ),
      PredicateRule<String>((v) => !isCommon(v), ValidationCode.commonPassword),
      PredicateRule<String>(
        (v) => !hasSequence(v),
        ValidationCode.sequentialCharacters,
      ),
      MustNotContainRule(
        RegExp(r'(.)\1{2,}'),
        ValidationCode.repeatedCharacters,
      ),
    ]);
  }

  final int minLength;
  final int maxLength;

  /// Name parts, email local part, phone digits… that must not appear.
  final List<String> personalData;
  late final CompositeValidator<String> _rules;

  @override
  ValidationError? validate(String value) => _rules.validate(value);

  /// All unmet rules, for a requirements checklist.
  List<ValidationError> unmet(String value) => _rules.validateAll(value);

  static bool isCommon(String value) {
    final lower = value.toLowerCase();
    if (kCommonPasswords.contains(lower)) return true;
    final stripped = lower.replaceAll(RegExp(r'[^a-z؀-ۿ]+$'), '');
    final leet = lower
        .replaceAll('@', 'a')
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll(r'$', 's')
        .replaceAll(RegExp(r'[^a-z0-9]+$'), '');
    return stripped.length >= 4 && kCommonPasswords.contains(stripped) ||
        kCommonPasswords.contains(leet);
  }

  /// 4+ characters in a row that step by +1 or -1 (`1234`, `dcba`).
  static bool hasSequence(String value, {int run = 4}) {
    final s = value.toLowerCase().codeUnits;
    var up = 1, down = 1;
    for (var i = 1; i < s.length; i++) {
      up = s[i] - s[i - 1] == 1 ? up + 1 : 1;
      down = s[i] - s[i - 1] == -1 ? down + 1 : 1;
      if (up >= run || down >= run) return true;
    }
    return false;
  }

  bool _containsPersonal(String value) {
    final lower = value.toLowerCase();
    return personalData
        .map((p) => p.trim().toLowerCase())
        .where((p) => p.length >= 3)
        .any(lower.contains);
  }
}

/// Rough 3-level score for UI feedback (not used for validation).
class PasswordStrengthEstimator {
  const PasswordStrengthEstimator();

  PasswordStrength estimate(String password) {
    if (password.isEmpty) return PasswordStrength.weak;
    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    if (PasswordValidator.isCommon(password) ||
        PasswordValidator.hasSequence(password)) {
      score = 0;
    }
    return score >= 5
        ? PasswordStrength.strong
        : score >= 3
        ? PasswordStrength.medium
        : PasswordStrength.weak;
  }
}
