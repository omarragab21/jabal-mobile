import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  final String id;
  final String name;
  final String phone; // E.164
  final String? email;

  @override
  List<Object?> get props => [id, name, phone, email];
}
