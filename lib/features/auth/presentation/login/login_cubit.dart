import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/countries/countries.dart';
import '../../domain/entities/phone_number.dart';
import '../../domain/usecases/login.dart';
import '../../domain/validators/auth_validation.dart';
import '../../domain/validators/digit_normalizer.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._login, this._validation) : super(LoginState());

  final Login _login;
  final AuthValidation _validation;

  String _phoneText = '';
  String _password = '';

  /// Once the user has tried to submit, fields re-validate while typing.
  bool _submitted = false;

  PhoneNumber get _phone => PhoneNumber(
    isoCode: state.country.isoCode,
    dialCode: state.country.dialCode,
    national: DigitNormalizer.toLatin(_phoneText),
  );

  void countryChanged(Country country) {
    emit(state.copyWith(country: country, failure: () => null));
    if (_submitted) {
      emit(
        state.copyWith(phoneError: () => _validation.phone.validate(_phone)),
      );
    }
  }

  void phoneChanged(String value) {
    _phoneText = value;
    emit(
      state.copyWith(
        status: LoginStatus.idle,
        failure: () => null,
        phoneError: _submitted
            ? () => _validation.phone.validate(_phone)
            : () => null,
      ),
    );
  }

  void passwordChanged(String value) {
    _password = value;
    emit(
      state.copyWith(
        status: LoginStatus.idle,
        failure: () => null,
        passwordError: _submitted
            ? () => _validation.loginPassword.validate(_password)
            : () => null,
      ),
    );
  }

  Future<void> submit() async {
    if (state.isLoading) return;
    _submitted = true;
    final phoneError = _validation.phone.validate(_phone);
    final passwordError = _validation.loginPassword.validate(_password);
    if (phoneError != null || passwordError != null) {
      emit(
        state.copyWith(
          status: LoginStatus.idle,
          phoneError: () => phoneError,
          passwordError: () => passwordError,
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, failure: () => null));
    final result = await _login(phone: _phone, password: _password);
    result.when(
      success: (_) =>
          emit(state.copyWith(status: LoginStatus.success, phone: _phone)),
      failure: (f) =>
          emit(state.copyWith(status: LoginStatus.failure, failure: () => f)),
    );
  }
}
