import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../formatters/orders_formatters.dart';
import 'order_status_chip.dart';

/// Top card of the details page: status, what it means now, the order number
/// and when it was placed.
class OrderStatusBanner extends StatelessWidget {
  const OrderStatusBanner({super.key, required this.order});

  final Order order;

  String _message(BuildContext context) {
    final key = switch (order.status) {
      OrderStatus.pendingApproval => 'pending_approval',
      OrderStatus.inPreparation => 'in_preparation',
      OrderStatus.onTheWay => 'on_the_way',
      OrderStatus.delivered => 'delivered',
      OrderStatus.cancelled =>
        order.cancelledBy == CancelledBy.store
            ? 'cancelled_by_store'
            : 'cancelled_by_customer',
    };
    return 'orders.banner.$key'.tr(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.buttonSecondary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          OrderStatusChip(status: order.status),
          SizedBox(height: 12.h),
          Text(
            _message(context),
            textAlign: TextAlign.center,
            style: AppTextStyles.textMdBold.copyWith(
              color: AppColors.textDefault,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            order.number,
            style: AppTextStyles.textLgBold.copyWith(
              color: AppColors.textDefault,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            OrdersFormatters.longDate(order.createdAt, lang),
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.textLabel,
            ),
          ),
        ],
      ),
    );
  }
}
