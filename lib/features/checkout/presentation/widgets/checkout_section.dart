import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A titled block of the checkout page with a hairline under it.
class CheckoutSection extends StatelessWidget {
  const CheckoutSection({
    super.key,
    required this.title,
    required this.child,
    this.divider = true,
  });

  final String title;
  final Widget child;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
          child: Text(
            title,
            style: AppTextStyles.textLgBold.copyWith(
              color: AppColors.textDefault,
            ),
          ),
        ),
        child,
        SizedBox(height: 16.h),
        if (divider) const Divider(height: 1, color: AppColors.cardBorder),
      ],
    );
  }
}
