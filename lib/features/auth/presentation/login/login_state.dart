import 'package:equatable/equatable.dart';

import '../../../../core/countries/countries.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/validation/validation_error.dart';
import '../../domain/entities/phone_number.dart';

enum LoginStatus { idle, loading, success, failure }

class LoginState extends Equatable {
  LoginState({
    Country? country,
    this.status = LoginStatus.idle,
    this.phoneError,
    this.passwordError,
    this.failure,
    this.phone,
  }) : country = country ?? Countries.defaultCountry;

  final Country country;
  final LoginStatus status;
  final ValidationError? phoneError;
  final ValidationError? passwordError;
  final Failure? failure;

  /// Set on success; the phone the code was sent to.
  final PhoneNumber? phone;

  bool get isLoading => status == LoginStatus.loading;

  LoginState copyWith({
    Country? country,
    LoginStatus? status,
    ValidationError? Function()? phoneError,
    ValidationError? Function()? passwordError,
    Failure? Function()? failure,
    PhoneNumber? phone,
  }) => LoginState(
    country: country ?? this.country,
    status: status ?? this.status,
    phoneError: phoneError != null ? phoneError() : this.phoneError,
    passwordError: passwordError != null ? passwordError() : this.passwordError,
    failure: failure != null ? failure() : this.failure,
    phone: phone ?? this.phone,
  );

  @override
  List<Object?> get props => [
    country,
    status,
    phoneError,
    passwordError,
    failure,
    phone,
  ];
}
