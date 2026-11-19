import '../../../../core/utils/result.dart';
import '../repositories/settings_repository.dart';

class GetNotificationsEnabled {
  const GetNotificationsEnabled(this._repository);
  final SettingsRepository _repository;

  Future<Result<bool>> call() => _repository.getNotificationsEnabled();
}

class SetNotificationsEnabled {
  const SetNotificationsEnabled(this._repository);
  final SettingsRepository _repository;

  Future<Result<void>> call(bool enabled) =>
      _repository.setNotificationsEnabled(enabled);
}

class DeleteAccount {
  const DeleteAccount(this._repository);
  final SettingsRepository _repository;

  Future<Result<void>> call() => _repository.deleteAccount();
}
