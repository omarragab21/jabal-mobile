import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'sheet_frame.dart';

/// "أين تريد التوصيل؟": search on the map, use the current location, or add
/// a new address. Shown while the customer has no saved address.
class DeliveryOptionsSheet extends StatelessWidget {
  const DeliveryOptionsSheet({
    super.key,
    required this.locating,
    this.errorText,
    required this.onSearchOnMap,
    required this.onUseCurrentLocation,
    required this.onAddNew,
  });

  /// The device position is being read.
  final bool locating;

  /// Why "use current location" failed, shown under the rows.
  final String? errorText;
  final VoidCallback onSearchOnMap;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'address.$key'.tr(context: context);
    Widget icon(String name) => SvgPicture.asset(
      'assets/icons/address/$name.svg',
      width: 24.r,
      height: 24.r,
    );
    return SheetFrame(
      title: t('where_to_deliver'),
      buttonLabel: t('add_new_address'),
      onButton: onAddNew,
      children: [
        SheetRow(
          leading: icon('search_map'),
          title: t('search_on_map'),
          onTap: onSearchOnMap,
        ),
        const SheetDivider(),
        SheetRow(
          leading: icon('my_location'),
          title: t('use_current_location'),
          busy: locating,
          onTap: onUseCurrentLocation,
        ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              errorText!,
              key: const ValueKey('location-error'),
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}
