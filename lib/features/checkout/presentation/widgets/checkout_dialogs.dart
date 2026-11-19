import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// A short explanation in a bottom sheet (handle, title, text and an
/// acknowledge button), used by the price summary rows.
Future<void> showCheckoutInfoSheet(
  BuildContext context, {
  required String title,
  required String message,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  barrierColor: AppColors.overlay.withValues(alpha: 0.35),
  builder: (sheet) => Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
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
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.textLabel,
              ),
            ),
            SizedBox(height: 16.h),
            AppButton(
              label: 'checkout.got_it'.tr(context: context),
              onPressed: () => Navigator.of(sheet).pop(),
            ),
          ],
        ),
      ),
    ),
  ),
);

/// "Order confirmed": thanks, and a button back to the home page.
Future<void> showOrderPlacedDialog(
  BuildContext context, {
  required String orderNumber,
}) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  barrierColor: AppColors.overlay.withValues(alpha: 0.5),
  builder: (dialog) => PopScope(
    canPop: false,
    child: Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 343.w,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'checkout.placed_title'.tr(context: context),
                style: AppTextStyles.textLgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'checkout.placed_message'.tr(context: context),
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textLabel,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                orderNumber,
                key: const ValueKey('placed-order-number'),
                style: AppTextStyles.textMdBold.copyWith(
                  color: AppColors.textDefault,
                ),
              ),
              SizedBox(height: 20.h),
              AppButton(
                label: 'checkout.back_home'.tr(context: context),
                onPressed: () => Navigator.of(dialog).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
