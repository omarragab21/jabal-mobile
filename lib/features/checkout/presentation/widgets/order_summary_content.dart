import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../cart/domain/entities/cart.dart';

/// "3 products" with a gift icon; tapping folds out the products.
class OrderSummaryContent extends StatefulWidget {
  const OrderSummaryContent({super.key, required this.cart});

  final Cart cart;

  @override
  State<OrderSummaryContent> createState() => _OrderSummaryContentState();
}

class _OrderSummaryContentState extends State<OrderSummaryContent> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final currency = 'home.currency'.tr(context: context);
    String money(double v) => '${v.toStringAsFixed(2)} $currency';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: const ValueKey('checkout-summary-toggle'),
          onTap: () => setState(() => _open = !_open),
          child: Row(
            children: [
              Icon(
                Icons.card_giftcard_outlined,
                size: 24.r,
                color: AppColors.textDefault,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'checkout.products_count'.tr(
                    context: context,
                    namedArgs: {'count': '${cart.itemsCount}'},
                  ),
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),
              ),
              Icon(
                _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 24.r,
                color: AppColors.textDefault,
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: _open
              ? Column(
                  children: [
                    for (final item in cart.items) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: const Divider(
                          height: 1,
                          color: AppColors.cardBorder,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56.r,
                            height: 56.r,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: AppNetworkImage(url: item.product.imageUrl),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: AppTextStyles.textMdRegular.copyWith(
                                    color: AppColors.textDefault,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'checkout.quantity'.tr(
                                    context: context,
                                    namedArgs: {'count': '${item.quantity}'},
                                  ),
                                  style: AppTextStyles.textSmRegular.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Wrap(
                                  spacing: 8.w,
                                  children: [
                                    Text(
                                      money(item.product.finalPrice),
                                      style: AppTextStyles.textMdBold.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    if (item.product.hasDiscount)
                                      Text(
                                        money(item.product.price),
                                        style: AppTextStyles.textSmRegular
                                            .copyWith(
                                              color: AppColors.textSecondary,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
