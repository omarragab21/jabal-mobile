import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "👀 200 viewing now": a white tab on the picture's bottom edge.
class ViewersChip extends StatelessWidget {
  const ViewersChip({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(12.w, 6.h, 16.w, 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.horizontal(
          start: Radius.circular(20.r),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14101828),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('👀', style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 6.w),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$count',
                  style: AppTextStyles.textSmBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                TextSpan(
                  text:
                      ' ${'product_details.viewers_now'.tr(context: context)}',
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
