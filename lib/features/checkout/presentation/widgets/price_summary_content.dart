import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/checkout_entities.dart';

/// What can be explained with a tap on a row's chevron.
enum PriceInfo { savings, discounts, delivery }

/// The payment summary: subtotal, savings, discounts, delivery, wallet and
/// the total to pay. Rows with a chevron explain themselves on tap.
class PriceSummaryContent extends StatelessWidget {
  const PriceSummaryContent({
    super.key,
    required this.pricing,
    required this.onInfo,
  });

  final CheckoutPricing pricing;
  final ValueChanged<PriceInfo> onInfo;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'checkout.$key'.tr(context: context);
    final currency = 'home.currency'.tr(context: context);
    String money(double v) => '${v.toStringAsFixed(2)} $currency';
    return Column(
      children: [
        _Row(label: t('subtotal'), value: money(pricing.subtotal)),
        _Row(
          key: const ValueKey('price-savings'),
          label: t('savings'),
          value: money(pricing.savings),
          color: AppColors.primary,
          onInfo: () => onInfo(PriceInfo.savings),
        ),
        if (pricing.promoDiscount > 0)
          _Row(
            key: const ValueKey('price-discounts'),
            label: t('discounts'),
            value: '- ${money(pricing.promoDiscount)}',
            onInfo: () => onInfo(PriceInfo.discounts),
          ),
        _Row(
          key: const ValueKey('price-delivery'),
          label: t('delivery_fee'),
          value: money(pricing.deliveryFee),
          onInfo: () => onInfo(PriceInfo.delivery),
        ),
        if (pricing.walletUsed > 0)
          _Row(
            key: const ValueKey('price-wallet'),
            label: t('from_wallet'),
            value: '- ${money(pricing.walletUsed)}',
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: const Divider(height: 1, color: AppColors.cardBorder),
        ),
        _Row(
          key: const ValueKey('price-total'),
          label: t('total'),
          value: money(pricing.payable),
          bold: true,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
    this.onInfo,
  });

  final String label;
  final String value;
  final Color? color;
  final bool bold;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    final style =
        (bold ? AppTextStyles.textMdBold : AppTextStyles.textMdRegular)
            .copyWith(color: color ?? AppColors.textDefault);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onInfo,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(label, style: style)),
                  if (onInfo != null) ...[
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20.r,
                      color: color ?? AppColors.textDefault,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }
}
