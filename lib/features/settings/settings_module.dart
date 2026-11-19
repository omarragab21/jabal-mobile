import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/settings_use_cases.dart';
import 'presentation/cubit/settings_cubit.dart';
import 'presentation/pages/settings_page.dart';

class SettingsModule {
  SettingsModule(LocalStorage storage)
    : _repository = SettingsRepositoryImpl(storage);

  final SettingsRepository _repository;

  Future<void> open(BuildContext context) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => SettingsCubit(
          getNotifications: GetNotificationsEnabled(_repository),
          setNotifications: SetNotificationsEnabled(_repository),
          deleteAccount: DeleteAccount(_repository),
        )..load(),
        child: const SettingsPage(),
      ),
    ),
  );
}
