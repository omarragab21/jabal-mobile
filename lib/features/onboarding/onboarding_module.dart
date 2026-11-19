import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';
import 'data/datasources/onboarding_local_data_source.dart';
import 'data/repositories/onboarding_repository_impl.dart';
import 'domain/entities/onboarding_pages_data.dart';
import 'domain/repositories/onboarding_repository.dart';
import 'domain/usecases/complete_onboarding.dart';
import 'domain/usecases/get_onboarding_seen.dart';
import 'presentation/onboarding/cubit/onboarding_cubit.dart';
import 'presentation/onboarding/pages/onboarding_page.dart';
import 'presentation/splash/cubit/splash_cubit.dart';
import 'presentation/splash/pages/splash_page.dart';

/// Wires the splash + onboarding feature. The rest of the app only needs
/// [splashPage] / [onboardingPage] and the two routes.
class OnboardingModule {
  OnboardingModule(LocalStorage storage)
    : _repository = OnboardingRepositoryImpl(
        OnboardingLocalDataSourceImpl(storage),
      );

  final OnboardingRepository _repository;

  Widget splashPage() => BlocProvider(
    create: (_) => SplashCubit(GetOnboardingSeen(_repository))..start(),
    child: const SplashPage(),
  );

  Widget onboardingPage() => BlocProvider(
    create: (_) => OnboardingCubit(
      CompleteOnboarding(_repository),
      pages: OnboardingPagesData.pages,
    ),
    child: const OnboardingScreen(),
  );
}
