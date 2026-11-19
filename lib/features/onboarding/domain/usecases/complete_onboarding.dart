import '../../../../core/utils/result.dart';
import '../repositories/onboarding_repository.dart';

/// Used for both "finish" and "skip": either way onboarding is not shown again.
class CompleteOnboarding {
  const CompleteOnboarding(this._repository);

  final OnboardingRepository _repository;

  Future<Result<void>> call() => _repository.markOnboardingSeen();
}
