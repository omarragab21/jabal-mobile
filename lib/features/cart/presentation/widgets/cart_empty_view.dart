import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// The empty cart: a bag with a plus, a title, a hint and a button to the
/// products.
class CartEmptyView extends StatelessWidget {
  const CartEmptyView({super.key, required this.onDiscover});

  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'cart.$key'.tr(context: context);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/cart_empty.svg',
              width: 56.r,
              height: 56.r,
            ),
            SizedBox(height: 24.h),
            Text(
              t('empty_title'),
              textAlign: TextAlign.center,
              style: AppTextStyles.textLgBold.copyWith(
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              t('empty_message'),
              textAlign: TextAlign.center,
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.textDefault,
              ),
            ),
            SizedBox(height: 24.h),
            AppButton(label: t('discover'), onPressed: onDiscover),
          ],
        ),
      ),
    );
  }
}
