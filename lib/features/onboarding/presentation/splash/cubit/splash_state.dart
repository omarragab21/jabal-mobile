import 'package:equatable/equatable.dart';

enum SplashDestination { onboarding, home }

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashNavigate extends SplashState {
  const SplashNavigate(this.destination);

  final SplashDestination destination;

  @override
  List<Object?> get props => [destination];
}
