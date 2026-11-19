import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// The line at the top of the home page: `التوصيل إلى **طبربور** ⌄`, or just
/// [question] (`أين تريد التوصيل؟`) while no place is chosen.
class DeliveryAddressBar extends StatelessWidget {
  const DeliveryAddressBar({
    super.key,
    required this.prefix,
    required this.question,
    this.place,
    this.onTap,
  });

  /// `التوصيل إلى`
  final String prefix;

  /// `أين تريد التوصيل؟`, shown when [place] is null.
  final String question;

  /// The chosen place's name, in bold after [prefix].
  final String? place;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.textMdRegular.copyWith(
      color: AppColors.textDefault,
    );
    final place = this.place;
    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 24.h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text.rich(
                  place == null || place.isEmpty
                      ? TextSpan(text: question)
                      : TextSpan(
                          children: [
                            TextSpan(text: '$prefix '),
                            TextSpan(
                              text: place,
                              style: AppTextStyles.textMdBold,
                            ),
                          ],
                        ),
                  style: base,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4.w),
              SvgPicture.asset(
                'assets/icons/home/chevron_down.svg',
                width: 24.r,
                height: 24.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
