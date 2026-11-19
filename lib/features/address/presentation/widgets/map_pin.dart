import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import 'hint_tooltip.dart';

/// The pin fixed at the map centre: a 44pt green square with a pin icon.
/// When [showUnavailable] is true the "no delivery here" bubble hangs under
/// it.
class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.showUnavailable});

  final bool showUnavailable;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44.r,
          height: 44.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: SvgPicture.asset(
            'assets/icons/address/pin_marker.svg',
            width: 24.r,
            height: 24.r,
          ),
        ),
        if (showUnavailable) ...[
          SizedBox(height: 4.h),
          HintTooltip(
            key: const ValueKey('not-deliverable'),
            width: 240,
            textAlign: TextAlign.center,
            text: 'address.not_deliverable'.tr(context: context),
          ),
        ],
      ],
    );
  }
}
