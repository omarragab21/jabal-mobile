import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary }

/// Full-width 44pt button from the design: green primary or light secondary.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.height = 44,
    this.greyWhenDisabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// 44 by default; compact places (dialogs) use 40.
  final double height;

  /// A disabled primary button turns light grey instead of a faded green
  /// (the map page's confirm button).
  final bool greyWhenDisabled;

  @override
  Widget build(BuildContext context) {
    final primary = variant == AppButtonVariant.primary;
    return SizedBox(
      width: double.infinity,
      height: height.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: primary
              ? AppColors.primary
              : AppColors.buttonSecondary,
          foregroundColor: primary
              ? AppColors.textOnColorPrimary
              : AppColors.textDefault,
          disabledBackgroundColor: primary && !greyWhenDisabled
              ? AppColors.primary.withValues(alpha: 0.5)
              : (greyWhenDisabled
                    ? AppColors.neutral200
                    : AppColors.buttonSecondary),
          disabledForegroundColor: primary && !greyWhenDisabled
              ? AppColors.textOnColorPrimary
              : (greyWhenDisabled
                    ? AppColors.textDisabled
                    : AppColors.textSecondary),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          textStyle: AppTextStyles.textMdRegular,
        ),
        child: Text(label),
      ),
    );
  }
}
