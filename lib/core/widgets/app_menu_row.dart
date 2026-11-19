import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A list row: leading icon, [label] (and an optional [subtitle]) and a
/// chevron at the end that points the way the language reads. A 1pt line
/// under the row when [showDivider].
class AppMenuRow extends StatelessWidget {
  const AppMenuRow({
    super.key,
    required this.label,
    this.iconAsset,
    this.leading,
    this.subtitle,
    this.trailing,
    this.badge,
    this.onTap,
    this.showDivider = true,
    this.showChevron = true,
    this.color = AppColors.textDefault,
  });

  final String label;

  /// An `assets/...svg`; drawn in [color] inside a 24pt box.
  final String? iconAsset;

  /// A ready-made leading widget, used instead of [iconAsset].
  final Widget? leading;
  final String? subtitle;

  /// Replaces the chevron (a switch, a value, ...).
  final Widget? trailing;

  /// A small label before the chevron ("current").
  final String? badge;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool showChevron;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ltr = Directionality.of(context) == TextDirection.ltr;
    final subtitle = this.subtitle;
    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: showDivider
                  ? const Border(
                      bottom: BorderSide(color: AppColors.neutral200),
                    )
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: 16.w),
                  ] else if (iconAsset != null) ...[
                    SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: SvgPicture.asset(
                        iconAsset!,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      ),
                    ),
                    SizedBox(width: 16.w),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.textMdRegular.copyWith(
                            color: color,
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            subtitle,
                            style: AppTextStyles.textSmRegular.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (badge != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        badge!,
                        style: AppTextStyles.textXsRegular.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  if (trailing != null)
                    trailing!
                  else if (showChevron)
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
          ),
        ),
      ),
    );
  }
}
