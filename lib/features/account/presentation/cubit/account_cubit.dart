import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/get_current_session.dart';
import '../../../auth/domain/usecases/logout.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit(this._getCurrentSession, this._logout)
    : super(const AccountState());

  final GetCurrentSession _getCurrentSession;
  final Logout _logout;

  Future<void> load() async {
    final result = await _getCurrentSession();
    result.when(
      success: (session) {
        if (session != null) {
          emit(
            state.copyWith(name: session.user.name, phone: session.user.phone),
          );
        }
      },
      failure: (_) {},
    );
  }

  Future<void> logout() async {
    await _logout();
    emit(state.copyWith(loggedOut: true));
  }
}
