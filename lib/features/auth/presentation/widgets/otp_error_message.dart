import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Red helper line under the OTP boxes ("ولايهمك، يمكن في رقم غلط…").
class OtpErrorMessage extends StatelessWidget {
  const OtpErrorMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: AppTextStyles.textSmRegular.copyWith(color: AppColors.error),
    );
  }
}
