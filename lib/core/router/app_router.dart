import 'package:flutter/material.dart';

import '../../features/auth/auth_module.dart';
import '../../features/auth/presentation/otp/otp_args.dart';
import '../../features/home/domain/entities/product.dart';
import '../../features/home/presentation/pages/category_args.dart';
import '../../features/main/main_module.dart';
import '../../features/onboarding/onboarding_module.dart';
import '../../features/product_details/presentation/product_details_args.dart';
import '../../features/product_details/product_details_module.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter({
    required this.onboarding,
    required this.auth,
    required this.main,
    required this.productDetails,
  });

  final OnboardingModule onboarding;
  final AuthModule auth;
  final MainModule main;
  final ProductDetailsModule productDetails;

  static void _openProduct(BuildContext context, Product product) =>
      Navigator.pushNamed(
        context,
        AppRoutes.product,
        arguments: ProductDetailsArgs(productId: product.id),
      );

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      AppRoutes.onboarding => onboarding.onboardingPage(),
      AppRoutes.gate => auth.gatePage(),
      AppRoutes.login => auth.loginPage(),
      AppRoutes.register => auth.registerPage(),
      AppRoutes.otp => auth.otpPage(settings.arguments as OtpArgs),
      AppRoutes.main => main.page(),
      AppRoutes.category => main.home.categoryPage(
        settings.arguments as CategoryArgs,
        onOpenCart: main.openCartTab,
        onOpenProduct: _openProduct,
      ),
      AppRoutes.product => productDetails.page(
        settings.arguments as ProductDetailsArgs,
        onOpenCart: main.openCartTab,
        onOpenCategory: (context, categoryId) => Navigator.pushNamed(
          context,
          AppRoutes.category,
          arguments: CategoryArgs(categoryId),
        ),
      ),
      _ => onboarding.splashPage(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
