import 'validation_error.dart';

/// One validation rule (or a combination of rules) for values of type [T].
/// Returns `null` when the value is valid.
abstract interface class Validator<T> {
  ValidationError? validate(T value);
}

/// Runs [validators] in order and reports the first failure. Build bigger
/// validators out of small single-purpose rules (Open/Closed): adding a rule
/// never changes the existing ones.
class CompositeValidator<T> implements Validator<T> {
  const CompositeValidator(this.validators);

  final List<Validator<T>> validators;

  @override
  ValidationError? validate(T value) {
    for (final v in validators) {
      final error = v.validate(value);
      if (error != null) return error;
    }
    return null;
  }

  /// Every failing rule (e.g. to show a checklist of unmet requirements).
  List<ValidationError> validateAll(T value) => [
    for (final v in validators) ?v.validate(value),
  ];
}
