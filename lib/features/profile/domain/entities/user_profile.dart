import 'package:equatable/equatable.dart';

enum Gender {
  male,
  female;

  static Gender? parse(String? name) {
    for (final gender in values) {
      if (gender.name == name) return gender;
    }
    return null;
  }
}

/// The customer's personal information.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.gender,
    this.birthDate,
  });

  final String id;
  final String name;

  /// E.164 (`+962791234567`).
  final String phone;
  final String? email;
  final Gender? gender;
  final DateTime? birthDate;

  UserProfile copyWith({
    String? name,
    String? phone,
    String? Function()? email,
    Gender? Function()? gender,
    DateTime? Function()? birthDate,
  }) => UserProfile(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email != null ? email() : this.email,
    gender: gender != null ? gender() : this.gender,
    birthDate: birthDate != null ? birthDate() : this.birthDate,
  );

  @override
  List<Object?> get props => [id, name, phone, email, gender, birthDate];
}
