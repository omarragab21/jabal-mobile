import 'validation_error.dart';
import 'validator.dart';

/// Not empty after trimming.
class RequiredRule implements Validator<String> {
  const RequiredRule();
  @override
  ValidationError? validate(String value) => value.trim().isEmpty
      ? const ValidationError(ValidationCode.required)
      : null;
}

class MinLengthRule implements Validator<String> {
  const MinLengthRule(this.min);
  final int min;
  @override
  ValidationError? validate(String value) => value.runes.length < min
      ? ValidationError(ValidationCode.tooShort, params: {'min': min})
      : null;
}

class MaxLengthRule implements Validator<String> {
  const MaxLengthRule(this.max);
  final int max;
  @override
  ValidationError? validate(String value) => value.runes.length > max
      ? ValidationError(ValidationCode.tooLong, params: {'max': max})
      : null;
}

class ExactLengthRule implements Validator<String> {
  const ExactLengthRule(this.length);
  final int length;
  @override
  ValidationError? validate(String value) => value.runes.length != length
      ? ValidationError(ValidationCode.wrongLength, params: {'length': length})
      : null;
}

/// Fails with [code] unless the whole value matches [pattern].
class MatchesRule implements Validator<String> {
  MatchesRule(this.pattern, this.code);
  final RegExp pattern;
  final ValidationCode code;
  @override
  ValidationError? validate(String value) =>
      pattern.hasMatch(value) ? null : ValidationError(code);
}

/// Fails with [code] when [pattern] is found anywhere in the value.
class MustNotContainRule implements Validator<String> {
  MustNotContainRule(this.pattern, this.code);
  final RegExp pattern;
  final ValidationCode code;
  @override
  ValidationError? validate(String value) =>
      pattern.hasMatch(value) ? ValidationError(code) : null;
}

/// Escape hatch for one-off checks without writing a class.
class PredicateRule<T> implements Validator<T> {
  const PredicateRule(this.isValid, this.code, {this.params = const {}});
  final bool Function(T value) isValid;
  final ValidationCode code;
  final Map<String, Object> params;
  @override
  ValidationError? validate(T value) =>
      isValid(value) ? null : ValidationError(code, params: params);
}
