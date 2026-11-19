import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_onboarding_seen.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._getOnboardingSeen, {
    this.minDuration = const Duration(seconds: 2),
  }) : super(const SplashLoading());

  final GetOnboardingSeen _getOnboardingSeen;
  final Duration minDuration;

  /// Waits for the minimum splash time, then decides where to go:
  /// onboarding already seen/skipped -> home, otherwise -> onboarding.
  Future<void> start() async {
    final minDelay = Future<void>.delayed(minDuration);
    final result = await _getOnboardingSeen();
    await minDelay;

    final seen = result.when(
      success: (seen) => seen,
      // If storage can't be read, showing onboarding is the safe default.
      failure: (_) => false,
    );
    emit(
      SplashNavigate(
        seen ? SplashDestination.home : SplashDestination.onboarding,
      ),
    );
  }
}
