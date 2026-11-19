import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order.dart';
import '../formatters/orders_formatters.dart';
import 'order_status_chip.dart';

/// One order in the list: number, date, status, products count and total.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.number,
                          style: AppTextStyles.textMdBold.copyWith(
                            color: AppColors.textDefault,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          OrdersFormatters.listDate(order.createdAt, lang),
                          style: AppTextStyles.textSmRegular.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Divider(height: 1, color: AppColors.neutral200),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'orders.items_count'.tr(
                        context: context,
                        namedArgs: {'count': '${order.itemsCount}'},
                      ),
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${OrdersFormatters.amount(order.total)} ${'orders.currency'.tr(context: context)}',
                    style: AppTextStyles.textSmBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
