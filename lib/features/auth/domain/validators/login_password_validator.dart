import '../../../../core/validation/string_rules.dart';
import '../../../../core/validation/validation_error.dart';
import '../../../../core/validation/validator.dart';

/// At login the password only has to be present: the strength policy applies
/// when it is created, and enforcing it here would lock out existing users.
class LoginPasswordValidator implements Validator<String> {
  const LoginPasswordValidator();

  @override
  ValidationError? validate(String value) =>
      const RequiredRule().validate(value);
}
