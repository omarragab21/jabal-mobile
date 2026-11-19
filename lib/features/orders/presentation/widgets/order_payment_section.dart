import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order.dart';
import '../formatters/orders_formatters.dart';

/// Payment method and paid/unpaid chip, then the price breakdown.
class OrderPaymentContent extends StatelessWidget {
  const OrderPaymentContent({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'orders.payment.$key'.tr(context: context);
    final currency = 'orders.currency'.tr(context: context);
    String money(double v) => '${OrdersFormatters.amount(v)} $currency';
    final payment = order.payment;
    final card = payment.method == PaymentMethod.card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (card) ...[
              _BrandBadge(brand: payment.cardBrand),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Text(
                card ? t('credit_card') : t('cash'),
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textDefault,
                ),
              ),
            ),
            _PaidChip(
              paid: payment.paid,
              label: t(payment.paid ? 'paid' : 'unpaid'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _AmountRow(label: t('subtotal'), value: money(order.subtotal)),
        _AmountRow(label: t('delivery_fee'), value: money(order.deliveryFee)),
        _AmountRow(label: t('discounts'), value: money(order.discount)),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: const Divider(height: 1, color: AppColors.neutral200),
        ),
        _AmountRow(label: t('total'), value: money(order.total), bold: true),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style =
        (bold ? AppTextStyles.textMdBold : AppTextStyles.textMdRegular)
            .copyWith(color: AppColors.textDefault);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _PaidChip extends StatelessWidget {
  const _PaidChip({required this.paid, required this.label});

  final bool paid;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = paid ? const Color(0xFF146914) : AppColors.textLabel;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: paid ? const Color(0xFFE3F6E3) : AppColors.neutral200,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: AppTextStyles.textSmRegular.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// The card network's name in its colour (no logo asset yet).
class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.brand});

  final String? brand;

  @override
  Widget build(BuildContext context) {
    final visa = brand == 'visa';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundBody,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Text(
        (brand ?? 'card').toUpperCase(),
        style: AppTextStyles.textXsBold.copyWith(
          color: visa ? const Color(0xFF172B85) : AppColors.textLabel,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
