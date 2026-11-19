import '../../../../core/validation/validator.dart';
import 'email_validator.dart';
import 'login_password_validator.dart';
import 'name_validator.dart';
import 'otp_validator.dart';
import 'password_validator.dart';
import 'phone_number_validator.dart';

/// Everything the auth cubits need to validate input, injected as a bundle.
class AuthValidation {
  AuthValidation({required this.phone})
    : name = NameValidator(),
      email = EmailValidator(),
      loginPassword = const LoginPasswordValidator(),
      otp = OtpValidator();

  final Validator<String> name;
  final Validator<String> email;
  final Validator<String> loginPassword;
  final Validator<String> otp;
  final PhoneNumberValidator phone;

  /// Sign-up password rules; [personalData] = name/email/phone fragments the
  /// password must not contain.
  Validator<String> signUpPassword({List<String> personalData = const []}) =>
      PasswordValidator(personalData: personalData);
}
