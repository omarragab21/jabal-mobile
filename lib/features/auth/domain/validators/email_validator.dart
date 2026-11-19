import '../../../../core/validation/string_rules.dart';
import '../../../../core/validation/validation_error.dart';
import '../../../../core/validation/validator.dart';

/// Email per the practical subset of RFC 5321/5322: one `@`, local part up to
/// 64 chars of allowed symbols (no leading/trailing/double dots), domain with
/// valid labels (≤63 chars, no leading/trailing hyphen) and an alphabetic TLD
/// of at least 2 letters, whole address ≤254.
class EmailValidator implements Validator<String> {
  EmailValidator() {
    _rules = CompositeValidator<String>([
      const RequiredRule(),
      const MaxLengthRule(254),
      MustNotContainRule(RegExp(r'\s'), ValidationCode.hasWhitespace),
      PredicateRule<String>(_hasSingleAt, ValidationCode.invalidFormat),
      PredicateRule<String>(_validLocal, ValidationCode.invalidFormat),
      PredicateRule<String>(_validDomain, ValidationCode.invalidFormat),
    ]);
  }

  late final CompositeValidator<String> _rules;

  static final _localChars = RegExp(r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+$");
  static final _label = RegExp(
    r'^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$',
  );
  static final _tld = RegExp(r'^[A-Za-z]{2,24}$');

  static String normalize(String value) => value.trim().toLowerCase();

  static bool _hasSingleAt(String v) => '@'.allMatches(v).length == 1;

  static bool _validLocal(String v) {
    final local = v.split('@').first;
    return local.isNotEmpty &&
        local.length <= 64 &&
        _localChars.hasMatch(local) &&
        !local.startsWith('.') &&
        !local.endsWith('.') &&
        !local.contains('..');
  }

  static bool _validDomain(String v) {
    final domain = v.split('@').last;
    final labels = domain.split('.');
    return labels.length >= 2 &&
        labels.every(_label.hasMatch) &&
        _tld.hasMatch(labels.last);
  }

  @override
  ValidationError? validate(String value) => _rules.validate(normalize(value));
}
