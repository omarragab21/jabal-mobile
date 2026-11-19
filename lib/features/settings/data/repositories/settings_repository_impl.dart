import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/settings_repository.dart';

/// Keeps the settings in [LocalStorage]. Deleting the account is local only
/// for now: a backend call goes in [deleteAccount] when the API has one.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._storage);

  final LocalStorage _storage;

  /// Everything that belongs to the signed-in customer.
  static const List<String> _accountKeys = [
    StorageKeys.authToken,
    StorageKeys.authUser,
    StorageKeys.profileExtras,
    StorageKeys.addresses,
    StorageKeys.deliverySelection,
    StorageKeys.paymentCards,
    StorageKeys.notificationsEnabled,
  ];

  @override
  Future<Result<bool>> getNotificationsEnabled() async => guard(
    () async => _storage.getBool(StorageKeys.notificationsEnabled) ?? true,
  );

  @override
  Future<Result<void>> setNotificationsEnabled(bool enabled) =>
      guard(() => _storage.setBool(StorageKeys.notificationsEnabled, enabled));

  @override
  Future<Result<void>> deleteAccount() => guard(() async {
    for (final key in _accountKeys) {
      await _storage.remove(key);
    }
  });
}
