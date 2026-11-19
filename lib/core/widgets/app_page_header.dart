import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Screen header: centered [title] and a back arrow at the start edge
/// (right in RTL, left in LTR). 58pt tall like the design.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = true,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;

  /// Tab roots have no back arrow.
  final bool showBack;

  /// Widget at the end edge (left in RTL), e.g. the cart button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      height: 58.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.textLgBold.copyWith(
              color: AppColors.textDefault,
            ),
          ),
          if (showBack)
            PositionedDirectional(
              start: 12.w,
              child: InkResponse(
                onTap: onBack ?? () => Navigator.maybePop(context),
                radius: 24.r,
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  // The asset points right (the RTL "back" direction), so it is
                  // mirrored in LTR.
                  child: Transform.flip(
                    flipX: !rtl,
                    child: SvgPicture.asset(
                      'assets/icons/arrow_back.svg',
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                ),
              ),
            ),
          if (trailing != null)
            PositionedDirectional(end: 12.w, child: trailing!),
        ],
      ),
    );
  }
}
