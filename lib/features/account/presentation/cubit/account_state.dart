import 'package:equatable/equatable.dart';

class AccountState extends Equatable {
  const AccountState({this.name, this.phone, this.loggedOut = false});

  final String? name;
  final String? phone;
  final bool loggedOut;

  AccountState copyWith({String? name, String? phone, bool? loggedOut}) =>
      AccountState(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        loggedOut: loggedOut ?? this.loggedOut,
      );

  @override
  List<Object?> get props => [name, phone, loggedOut];
}
