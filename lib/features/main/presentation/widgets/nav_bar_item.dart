import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/count_badge.dart';

/// One tab: a 4pt green bar on top when selected, 24pt icon (outline when
/// idle, filled when selected), optional [badgeCount] and the label.
class NavBarItem extends StatelessWidget {
  const NavBarItem({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.activeIconAsset,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final String iconAsset;
  final String activeIconAsset;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
        child: Column(
          children: [
            Container(
              height: 4.h,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
              ),
            ),
            SizedBox(height: 8.h),
            Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  selected ? activeIconAsset : iconAsset,
                  width: 24.w,
                  height: 24.h,
                ),
                if (badgeCount > 0)
                  PositionedDirectional(
                    end: -18.7.w,
                    top: -3.h,
                    child: CountBadge(count: badgeCount),
                  ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.textXsRegular.copyWith(
                color: selected ? AppColors.primary : AppColors.textLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
