import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/onboarding_page.dart';
import '../../../domain/usecases/complete_onboarding.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(
    this._completeOnboarding, {
    required List<OnboardingPage> pages,
  }) : super(OnboardingState(pages: pages));

  final CompleteOnboarding _completeOnboarding;

  void pageChanged(int index) => emit(state.copyWith(currentIndex: index));

  /// "Next" on every page except the last, where it finishes onboarding.
  /// The page controller is driven by the UI reacting to [currentIndex].
  Future<void> next() async {
    if (state.isLastPage) return complete();
    emit(state.copyWith(currentIndex: state.currentIndex + 1));
  }

  Future<void> skip() => complete();

  /// Saves the "seen" flag so onboarding never shows again, then leaves.
  /// A failed save must not trap the user, so we leave either way.
  Future<void> complete() async {
    await _completeOnboarding();
    emit(state.copyWith(isCompleted: true));
  }
}
