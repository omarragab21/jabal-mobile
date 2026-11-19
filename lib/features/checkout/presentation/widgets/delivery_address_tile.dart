import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../address/domain/entities/address_type.dart';
import '../../../address/domain/entities/delivery_location.dart';
import '../../../address/presentation/widgets/address_type_icon.dart';

/// Where the order goes: the address's icon, name and details; the whole row
/// opens the address chooser. With no address chosen it asks for one.
class DeliveryAddressTile extends StatelessWidget {
  const DeliveryAddressTile({
    super.key,
    required this.location,
    required this.type,
    required this.phone,
    required this.onTap,
  });

  final DeliveryLocation? location;

  /// The saved address's kind, for its icon.
  final AddressType type;
  final String phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final place = location;
    final details = place == null
        ? null
        : [place.details, if (phone.isNotEmpty) phone].join(' ، ');
    return InkWell(
      key: const ValueKey('checkout-address'),
      onTap: onTap,
      child: Row(
        children: [
          AddressTypeIcon(type),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place?.label ??
                      'checkout.choose_address'.tr(context: context),
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),
                if (details != null)
                  Text(
                    details,
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          // Points to the end edge: left in Arabic (Material mirrors it).
          Icon(Icons.chevron_right, size: 24.r, color: AppColors.textDefault),
        ],
      ),
    );
  }
}
