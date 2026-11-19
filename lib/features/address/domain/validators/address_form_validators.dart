import '../../../../core/validation/string_rules.dart';
import '../../../../core/validation/validator.dart';

/// Rules for the address details form.
class AddressFormValidators {
  AddressFormValidators()
    : title = CompositeValidator<String>([
        const RequiredRule(),
        const MinLengthRule(2),
        const MaxLengthRule(30),
      ]),
      detail = CompositeValidator<String>([
        const RequiredRule(),
        const MaxLengthRule(60),
      ]),
      number = CompositeValidator<String>([
        const RequiredRule(),
        const MaxLengthRule(10),
      ]),
      instructions = const MaxLengthRule(120);

  /// The name the customer gives the address ("My Home").
  final Validator<String> title;

  /// Building name / description of the place.
  final Validator<String> detail;

  /// House, floor, apartment or office number.
  final Validator<String> number;

  /// Optional notes for the courier.
  final Validator<String> instructions;
}
