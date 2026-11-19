import 'onboarding_page.dart';

/// Static onboarding content (copied from Figma), in display order.
/// Texts live in `assets/translations/*.json`.
abstract final class OnboardingPagesData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      imageAsset: 'assets/images/onboarding_1.png',
      titleKey: 'onboarding.page1.title',
      descriptionKey: 'onboarding.page1.description',
      buttonKey: 'onboarding.next',
    ),
    OnboardingPage(
      imageAsset: 'assets/images/onboarding_2.png',
      titleKey: 'onboarding.page2.title',
      descriptionKey: 'onboarding.page2.description',
      buttonKey: 'onboarding.next',
    ),
    OnboardingPage(
      imageAsset: 'assets/images/onboarding_3.png',
      titleKey: 'onboarding.page3.title',
      descriptionKey: 'onboarding.page3.description',
      buttonKey: 'onboarding.start',
    ),
  ];
}
