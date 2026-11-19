import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_session.dart';

enum AuthGateDestination { checking, login, home }

/// Decides where to go once onboarding is out of the way: a saved session
/// goes straight to home, otherwise to login.
class AuthGateCubit extends Cubit<AuthGateDestination> {
  AuthGateCubit(this._getCurrentSession) : super(AuthGateDestination.checking);

  final GetCurrentSession _getCurrentSession;

  Future<void> check() async {
    final result = await _getCurrentSession();
    final session = result.when(success: (s) => s, failure: (_) => null);
    emit(
      session == null ? AuthGateDestination.login : AuthGateDestination.home,
    );
  }
}
