import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state case SplashNavigate(:final destination)) {
          Navigator.of(context).pushReplacementNamed(switch (destination) {
            SplashDestination.onboarding => AppRoutes.onboarding,
            SplashDestination.home => AppRoutes.gate,
          });
        }
      },
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            const Center(child: _CenterBrand()),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Text(
                  'splash.footer'.tr(context: context),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.textOnColorPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterBrand extends StatelessWidget {
  const _CenterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96.w,
          height: 96.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000), // rgba(0,0,0,0.12)
                offset: Offset(0, 8),
                blurRadius: 8.r,
              ),
            ],
          ),
          child: SvgPicture.asset(
            'assets/icons/splash_logo.svg',
            width: 43.w,
            height: 39.h,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'splash.title'.tr(context: context),
          style: AppTextStyles.displaySmBold.copyWith(
            color: AppColors.textOnColorPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'splash.tagline'.tr(context: context),
          style: AppTextStyles.textSmRegular.copyWith(
            color: AppColors.textOnColorPrimary,
          ),
        ),
      ],
    );
  }
}
