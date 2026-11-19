import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';

abstract interface class OnboardingLocalDataSource {
  bool isOnboardingSeen();
  Future<void> setOnboardingSeen();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  const OnboardingLocalDataSourceImpl(this._storage);

  final LocalStorage _storage;

  @override
  bool isOnboardingSeen() =>
      _storage.getBool(StorageKeys.onboardingSeen) ?? false;

  @override
  Future<void> setOnboardingSeen() =>
      _storage.setBool(StorageKeys.onboardingSeen, true);
}
