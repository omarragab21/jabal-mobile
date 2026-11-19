import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/countries/countries.dart';
import '../../../../core/validation/validation_error.dart';
import '../../domain/entities/phone_number.dart';
import '../../domain/entities/registration_data.dart';
import '../../domain/usecases/register.dart';
import '../../domain/validators/auth_validation.dart';
import '../../domain/validators/digit_normalizer.dart';
import '../../domain/validators/email_validator.dart';
import '../../domain/validators/name_validator.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._register, this._validation) : super(RegisterState());

  final Register _register;
  final AuthValidation _validation;

  String _name = '';
  String _email = '';
  String _phoneText = '';
  String _password = '';
  bool _submitted = false;

  PhoneNumber get _phone => PhoneNumber(
    isoCode: state.country.isoCode,
    dialCode: state.country.dialCode,
    national: DigitNormalizer.toLatin(_phoneText),
  );

  ValidationError? _nameError() => _validation.name.validate(_name);
  ValidationError? _emailError() => _validation.email.validate(_email);
  ValidationError? _phoneError() => _validation.phone.validate(_phone);

  /// The password may not be built from the user's own data.
  ValidationError? _passwordError() => _validation
      .signUpPassword(
        personalData: [
          ...NameValidator.normalize(_name).split(' '),
          EmailValidator.normalize(_email).split('@').first,
          _phone.nationalDigits,
        ],
      )
      .validate(_password);

  void countryChanged(Country country) {
    emit(state.copyWith(country: country, failure: () => null));
    if (_submitted) emit(state.copyWith(phoneError: _phoneError));
  }

  void nameChanged(String v) {
    _name = v;
    _touch(nameError: _submitted ? _nameError : () => null);
  }

  void emailChanged(String v) {
    _email = v;
    _touch(emailError: _submitted ? _emailError : () => null);
  }

  void phoneChanged(String v) {
    _phoneText = v;
    _touch(phoneError: _submitted ? _phoneError : () => null);
  }

  void passwordChanged(String v) {
    _password = v;
    _touch(passwordError: _submitted ? _passwordError : () => null);
  }

  void _touch({
    ValidationError? Function()? nameError,
    ValidationError? Function()? emailError,
    ValidationError? Function()? phoneError,
    ValidationError? Function()? passwordError,
  }) {
    emit(
      state.copyWith(
        status: RegisterStatus.idle,
        failure: () => null,
        nameError: nameError,
        emailError: emailError,
        phoneError: phoneError,
        passwordError: passwordError,
      ),
    );
    // Name/email/phone feed the password's personal-data rule.
    if (_submitted && passwordError == null && _password.isNotEmpty) {
      emit(state.copyWith(passwordError: _passwordError));
    }
  }

  Future<void> submit() async {
    if (state.isLoading) return;
    _submitted = true;
    final nameError = _nameError();
    final emailError = _emailError();
    final phoneError = _phoneError();
    final passwordError = _passwordError();
    if (nameError != null ||
        emailError != null ||
        phoneError != null ||
        passwordError != null) {
      emit(
        state.copyWith(
          status: RegisterStatus.idle,
          nameError: () => nameError,
          emailError: () => emailError,
          phoneError: () => phoneError,
          passwordError: () => passwordError,
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading, failure: () => null));
    final phone = _phone;
    final result = await _register(
      RegistrationData(
        name: NameValidator.normalize(_name),
        email: EmailValidator.normalize(_email),
        phone: phone,
        password: _password,
      ),
    );
    result.when(
      success: (_) =>
          emit(state.copyWith(status: RegisterStatus.success, phone: phone)),
      failure: (f) => emit(
        state.copyWith(status: RegisterStatus.failure, failure: () => f),
      ),
    );
  }
}
