import '../../../../core/utils/result.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._local);

  final OnboardingLocalDataSource _local;

  @override
  Future<Result<bool>> isOnboardingSeen() async =>
      guard(() async => _local.isOnboardingSeen());

  @override
  Future<Result<void>> markOnboardingSeen() =>
      guard(() => _local.setOnboardingSeen());
}
