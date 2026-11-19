import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Top bar: skip (start side) and language switch (end side).
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key, required this.onSkip, this.onLanguageTap});

  final VoidCallback onSkip;
  final VoidCallback? onLanguageTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _HeaderButton(
            label: 'onboarding.skip'.tr(context: context),
            onTap: onSkip,
          ),
          _HeaderButton(
            label: 'onboarding.switch_language'.tr(context: context),
            onTap: onLanguageTap,
            icon: SvgPicture.asset(
              'assets/icons/language.svg',
              width: 14.3333.w,
              height: 14.3338.h,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback? onTap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              SizedBox(
                width: 16.w,
                height: 16.h,
                child: Center(child: icon),
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: AppTextStyles.textXsRegular.copyWith(
                color: AppColors.textDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
