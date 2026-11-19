import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/settings_use_cases.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.notificationsEnabled = true,
    this.deleting = false,
    this.deleted = false,
    this.deleteFailed = false,
  });

  final bool notificationsEnabled;
  final bool deleting;
  final bool deleted;
  final bool deleteFailed;

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? deleting,
    bool? deleted,
    bool? deleteFailed,
  }) => SettingsState(
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    deleting: deleting ?? this.deleting,
    deleted: deleted ?? this.deleted,
    deleteFailed: deleteFailed ?? this.deleteFailed,
  );

  @override
  List<Object?> get props => [
    notificationsEnabled,
    deleting,
    deleted,
    deleteFailed,
  ];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required GetNotificationsEnabled getNotifications,
    required SetNotificationsEnabled setNotifications,
    required DeleteAccount deleteAccount,
  }) : _getNotifications = getNotifications,
       _setNotifications = setNotifications,
       _deleteAccount = deleteAccount,
       super(const SettingsState());

  final GetNotificationsEnabled _getNotifications;
  final SetNotificationsEnabled _setNotifications;
  final DeleteAccount _deleteAccount;

  Future<void> load() async {
    final enabled = (await _getNotifications()).when(
      success: (value) => value,
      failure: (_) => true,
    );
    if (!isClosed) emit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setNotifications(bool enabled) async {
    emit(state.copyWith(notificationsEnabled: enabled));
    final saved = (await _setNotifications(
      enabled,
    )).when(success: (_) => true, failure: (_) => false);
    // The switch must show what is really saved.
    if (!saved && !isClosed) {
      emit(state.copyWith(notificationsEnabled: !enabled));
    }
  }

  Future<void> deleteAccount() async {
    if (state.deleting) return;
    emit(state.copyWith(deleting: true, deleteFailed: false));
    final result = await _deleteAccount();
    if (isClosed) return;
    result.when(
      success: (_) => emit(state.copyWith(deleting: false, deleted: true)),
      failure: (_) => emit(state.copyWith(deleting: false, deleteFailed: true)),
    );
  }
}
