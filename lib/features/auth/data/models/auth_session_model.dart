import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
    id: '${json['id']}',
    name: json['name'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
  };
}

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({required super.token, required AuthUserModel user})
    : super(user: user);

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        token: json['token'] as String,
        user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}
