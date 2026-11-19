import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/order.dart';
import '../formatters/orders_formatters.dart';

/// The ordered products, one row each: picture, name, quantity, prices and
/// the customer's note.
class OrderProductsList extends StatelessWidget {
  const OrderProductsList({super.key, required this.items});

  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(height: 1, color: AppColors.neutral200),
            ),
          _ProductRow(item: items[i]),
        ],
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final currency = 'orders.currency'.tr(context: context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: AppNetworkImage(url: item.imageUrl),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textDefault,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'orders.quantity'.tr(
                  context: context,
                  namedArgs: {'count': '${item.quantity}'},
                ),
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.w,
                children: [
                  Text(
                    '${OrdersFormatters.amount(item.price)} $currency',
                    style: AppTextStyles.textMdBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  if (item.hasDiscount)
                    Text(
                      '${OrdersFormatters.amount(item.originalPrice!)} $currency',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
              if (item.note != null) ...[
                SizedBox(height: 4.h),
                Text(
                  item.note!,
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
