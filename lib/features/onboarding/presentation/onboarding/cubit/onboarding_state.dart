import 'package:equatable/equatable.dart';

import '../../../domain/entities/onboarding_page.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    required this.pages,
    this.currentIndex = 0,
    this.isCompleted = false,
  });

  final List<OnboardingPage> pages;
  final int currentIndex;

  /// Set once onboarding was finished or skipped -> UI leaves to home.
  final bool isCompleted;

  bool get isLastPage => currentIndex == pages.length - 1;
  OnboardingPage get currentPage => pages[currentIndex];

  OnboardingState copyWith({int? currentIndex, bool? isCompleted}) =>
      OnboardingState(
        pages: pages,
        currentIndex: currentIndex ?? this.currentIndex,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  @override
  List<Object?> get props => [pages, currentIndex, isCompleted];
}
