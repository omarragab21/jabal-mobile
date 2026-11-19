import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Bottom sheet with a drag handle, a centred [title] and [children].
Future<T?> showOptionsSheet<T>(
  BuildContext context, {
  required String title,
  required List<Widget> children,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (ctx) => Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
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
            ...children,
          ],
        ),
      ),
    ),
  ),
);
