import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// Frame of the address bottom sheets: drag handle, centred [title], the
/// [children] and a full-width primary button at the bottom.
class SheetFrame extends StatelessWidget {
  const SheetFrame({
    super.key,
    required this.title,
    required this.children,
    required this.buttonLabel,
    required this.onButton,
  });

  final String title;
  final List<Widget> children;
  final String buttonLabel;
  final VoidCallback onButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24.w,
            0,
            24.w,
            MediaQuery.viewPaddingOf(context).bottom > 0 ? 8.h : 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 24.h, bottom: 16.h),
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.textLgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: children,
                ),
              ),
              SizedBox(height: 16.h),
              AppButton(label: buttonLabel, onPressed: onButton),
            ],
          ),
        ),
      ),
    );
  }
}

/// A sheet row: [leading] icon, [title] and optional [subtitle], and a
/// chevron at the end that points the way the language reads.
class SheetRow extends StatelessWidget {
  const SheetRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.busy = false,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;

  /// Shows a spinner instead of the chevron.
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ltr = Directionality.of(context) == TextDirection.ltr;
    final subtitle = this.subtitle;
    return InkWell(
      onTap: busy ? null : onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            leading,
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.textMdRegular.copyWith(
                      color: AppColors.textDefault,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            if (busy)
              SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              // The asset points left (the RTL "go" direction).
              Transform.flip(
                flipX: ltr,
                child: SvgPicture.asset(
                  'assets/icons/address/chevron.svg',
                  width: 24.r,
                  height: 24.r,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 1pt grey line between sheet rows.
class SheetDivider extends StatelessWidget {
  const SheetDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppColors.neutral200);
}
