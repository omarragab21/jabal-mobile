import '../../../../core/utils/result.dart';
import '../repositories/onboarding_repository.dart';

class GetOnboardingSeen {
  const GetOnboardingSeen(this._repository);

  final OnboardingRepository _repository;

  Future<Result<bool>> call() => _repository.isOnboardingSeen();
}
