import 'package:equatable/equatable.dart';

/// Content of a single onboarding step. Texts are translation keys.
class OnboardingPage extends Equatable {
  const OnboardingPage({
    required this.imageAsset,
    required this.titleKey,
    required this.descriptionKey,
    required this.buttonKey,
  });

  final String imageAsset;
  final String titleKey;
  final String descriptionKey;
  final String buttonKey;

  @override
  List<Object?> get props => [imageAsset, titleKey, descriptionKey, buttonKey];
}
