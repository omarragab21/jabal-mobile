import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// Red pill with a count; anything above [max] shows as `99+`.
class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, this.max = 99});

  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final text = count > max ? '$max+' : '$count';
    return Container(
      constraints: BoxConstraints(minWidth: 16.r),
      height: 16.h,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.badge,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontFamily: AppFonts.family,
          fontSize: 11.sp,
          height: 1.2,
          fontWeight: AppFonts.bold,
          color: AppColors.white,
        ),
      ),
    );
  }
}
