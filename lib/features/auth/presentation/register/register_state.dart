import 'package:equatable/equatable.dart';

import '../../../../core/countries/countries.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/validation/validation_error.dart';
import '../../domain/entities/phone_number.dart';

enum RegisterStatus { idle, loading, success, failure }

class RegisterState extends Equatable {
  RegisterState({
    Country? country,
    this.status = RegisterStatus.idle,
    this.nameError,
    this.emailError,
    this.phoneError,
    this.passwordError,
    this.failure,
    this.phone,
  }) : country = country ?? Countries.defaultCountry;

  final Country country;
  final RegisterStatus status;
  final ValidationError? nameError;
  final ValidationError? emailError;
  final ValidationError? phoneError;
  final ValidationError? passwordError;
  final Failure? failure;
  final PhoneNumber? phone;

  bool get isLoading => status == RegisterStatus.loading;

  RegisterState copyWith({
    Country? country,
    RegisterStatus? status,
    ValidationError? Function()? nameError,
    ValidationError? Function()? emailError,
    ValidationError? Function()? phoneError,
    ValidationError? Function()? passwordError,
    Failure? Function()? failure,
    PhoneNumber? phone,
  }) => RegisterState(
    country: country ?? this.country,
    status: status ?? this.status,
    nameError: nameError != null ? nameError() : this.nameError,
    emailError: emailError != null ? emailError() : this.emailError,
    phoneError: phoneError != null ? phoneError() : this.phoneError,
    passwordError: passwordError != null ? passwordError() : this.passwordError,
    failure: failure != null ? failure() : this.failure,
    phone: phone ?? this.phone,
  );

  @override
  List<Object?> get props => [
    country,
    status,
    nameError,
    emailError,
    phoneError,
    passwordError,
    failure,
    phone,
  ];
}
