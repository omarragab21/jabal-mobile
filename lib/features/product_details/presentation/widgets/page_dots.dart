import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Short rounded bars, one per picture; the current one is green.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (count < 2) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            width: 28.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: i == index ? AppColors.primary : AppColors.neutral200,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
      ],
    );
  }
}
