import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../domain/entities/cart.dart';

/// One cart row: picture with an edit button, name, size, prices and the
/// quantity control (a bin instead of the minus while there is just one).
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItem item;
  final VoidCallback onEdit;
  final VoidCallback? onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final currency = 'home.currency'.tr(context: context);
    String money(double v) => '${v.toStringAsFixed(2)} $currency';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Picture(
          url: product.imageUrl,
          onEdit: onEdit,
          editLabel: 'cart.edit_item'.tr(context: context),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textDefault,
                ),
              ),
              if (product.sizeLabel != null) ...[
                SizedBox(height: 4.h),
                Text(
                  product.sizeLabel!,
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.textLabel,
                  ),
                ),
              ],
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    money(product.finalPrice),
                    style: AppTextStyles.textMdBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  if (product.hasDiscount)
                    Text(
                      money(product.price),
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              QuantityStepper(
                key: ValueKey('cart-stepper-${product.id}'),
                quantity: item.quantity,
                onDecrement: onDecrement,
                onIncrement: onIncrement,
                decrementAsset: item.quantity > 1
                    ? null
                    : 'assets/icons/trash.svg',
                decrementLabel:
                    (item.quantity > 1 ? 'cart.decrease' : 'cart.remove_item')
                        .tr(context: context),
                incrementLabel: 'cart.increase'.tr(context: context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Picture extends StatelessWidget {
  const _Picture({
    required this.url,
    required this.onEdit,
    required this.editLabel,
  });

  final String? url;
  final VoidCallback onEdit;
  final String editLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112.r,
      height: 112.r,
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: url),
            PositionedDirectional(
              top: 6.r,
              end: 6.r,
              child: Semantics(
                button: true,
                label: editLabel,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onEdit,
                  child: Container(
                    key: const ValueKey('cart-edit'),
                    width: 36.r,
                    height: 36.r,
                    decoration: const BoxDecoration(
                      color: Color(0xCCF2F4F7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 20.r,
                      color: AppColors.textDefault,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
