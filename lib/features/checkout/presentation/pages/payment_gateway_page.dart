import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// Stand-in for the payment gateway (a web view in the real app: card
/// verification and 3-D Secure). It pops with true when the payment or the
/// verification went through and with false when it did not. The two buttons
/// exist only to drive the demo until the gateway is connected.
class PaymentGatewayPage extends StatelessWidget {
  const PaymentGatewayPage({super.key});

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'checkout.$key'.tr(context: context);
    return Scaffold(
      backgroundColor: AppColors.backgroundBody,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              Text(
                t('gateway_title'),
                textAlign: TextAlign.center,
                style: AppTextStyles.displaySmBold.copyWith(
                  color: AppColors.textDefault,
                ),
              ),
              const Spacer(),
              Text(
                t('gateway_demo_note'),
                textAlign: TextAlign.center,
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              AppButton(
                key: const ValueKey('gateway-pay'),
                label: t('gateway_complete'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              SizedBox(height: 8.h),
              AppButton(
                key: const ValueKey('gateway-cancel'),
                label: t('gateway_cancel'),
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
