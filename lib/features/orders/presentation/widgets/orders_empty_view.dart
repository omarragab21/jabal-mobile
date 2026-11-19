import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// Empty list: a gift icon, a title, a hint and a button that leads to the
/// products.
class OrdersEmptyView extends StatelessWidget {
  const OrdersEmptyView({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 56.r,
              color: AppColors.primary,
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.textLgBold.copyWith(
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.textDefault,
              ),
            ),
            SizedBox(height: 24.h),
            AppButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}
