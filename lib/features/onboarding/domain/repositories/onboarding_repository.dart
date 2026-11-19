import '../../../../core/utils/result.dart';

abstract interface class OnboardingRepository {
  /// Whether the user already finished or skipped onboarding.
  Future<Result<bool>> isOnboardingSeen();

  /// Remembers that onboarding was finished or skipped.
  Future<Result<void>> markOnboardingSeen();
}
