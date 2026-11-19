import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';

/// Row of small bars; the active one is wider and green.
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: 4.w),
          Container(
            width: i == index ? 28 : 14,
            height: 4.h,
            decoration: BoxDecoration(
              color: i == index ? AppColors.primary : AppColors.neutral200,
              borderRadius: BorderRadius.circular(104.r),
            ),
          ),
        ],
      ],
    );
  }
}
