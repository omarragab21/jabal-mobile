import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/onboarding_page.dart';

/// One onboarding step: image, title and description.
class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({
    super.key,
    required this.page,
    required this.imageHeight,
  });

  final OnboardingPage page;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Image.asset(page.imageAsset, fit: BoxFit.cover),
            ),
          ),
        ),
        SizedBox(height: 58.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.5.w),
          child: Column(
            children: [
              Text(
                page.titleKey.tr(context: context),
                textAlign: TextAlign.center,
                style: AppTextStyles.displayXsBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
              SizedBox(height: 16.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 310.w),
                child: Text(
                  page.descriptionKey.tr(context: context),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
