import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// "This account can't be used" card: title + close at the top, message and a
/// "contact support" button. 320pt wide like the design.
class AccountBlockedDialog extends StatelessWidget {
  const AccountBlockedDialog({
    super.key,
    required this.title,
    required this.message,
    required this.contactLabel,
    required this.onClose,
    required this.onContactSupport,
  });

  final String title;
  final String message;
  final String contactLabel;
  final VoidCallback onClose;
  final VoidCallback onContactSupport;

  /// Shows the dialog over the current screen.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required String contactLabel,
    required VoidCallback onContactSupport,
  }) => showDialog<void>(
    context: context,
    barrierColor: AppColors.overlay.withValues(alpha: 0.5),
    builder: (ctx) => Center(
      child: Material(
        type: MaterialType.transparency,
        child: AccountBlockedDialog(
          title: title,
          message: message,
          contactLabel: contactLabel,
          onClose: () => Navigator.of(ctx).pop(),
          onContactSupport: () {
            Navigator.of(ctx).pop();
            onContactSupport();
          },
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320.w,
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlay.withValues(alpha: 0.12),
            blurRadius: 32.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    title,
                    style: AppTextStyles.textLgBold.copyWith(
                      color: AppColors.textDisplay,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _CloseButton(onTap: onClose),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.textLabel,
            ),
          ),
          SizedBox(height: 16.h),
          AppButton(
            label: contactLabel,
            height: 40,
            onPressed: onContactSupport,
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.buttonSecondary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox.square(
          dimension: 32.r,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/close.svg',
              width: 24.w,
              height: 24.h,
            ),
          ),
        ),
      ),
    );
  }
}
