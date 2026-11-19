import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Small green "نسيت كلمة المرور" link under the password field.
class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: InkWell(
          onTap: onTap,
          child: Text(
            label,
            style: AppTextStyles.textXsRegular.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
