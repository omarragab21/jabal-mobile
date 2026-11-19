import 'package:equatable/equatable.dart';

import 'phone_number.dart';

/// Input of the sign-up form.
class RegistrationData extends Equatable {
  const RegistrationData({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String name;
  final String email;
  final PhoneNumber phone;
  final String password;

  @override
  List<Object?> get props => [name, email, phone, password];
}
