import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import 'auth_gate_cubit.dart';

/// Invisible hop between onboarding/splash and the app: routes to home when a
/// session exists, otherwise to login.
class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthGateCubit, AuthGateDestination>(
      listener: (context, destination) {
        final route = switch (destination) {
          AuthGateDestination.home => AppRoutes.main,
          AuthGateDestination.login => AppRoutes.login,
          AuthGateDestination.checking => null,
        };
        if (route != null) {
          Navigator.of(context).pushReplacementNamed(route);
        }
      },
      child: const Scaffold(backgroundColor: AppColors.backgroundBody),
    );
  }
}
