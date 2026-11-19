import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// "Are you sure?" dialog: [title], [message] and two buttons, the
/// confirming one first. Returns true when it was confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: AppColors.overlay.withValues(alpha: 0.5),
    builder: (ctx) => Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 320.w,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.textLgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 20.h),
              AppButton(
                label: confirmLabel,
                height: 40,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
              SizedBox(height: 8.h),
              AppButton(
                label: cancelLabel,
                height: 40,
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return confirmed ?? false;
}
