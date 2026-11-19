import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/product.dart';

/// `4.25` — prices always show two decimals.
String formatPrice(double amount) => amount.toStringAsFixed(2);

/// Product tile (design: product-item, 160 x 348): picture with a heart,
/// category, name, size, price (old price crossed out) and the add button.
/// It fills the width its parent gives it.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.currency,
    required this.addToCartLabel,
    required this.favoriteLabel,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
    this.onAddToCart,
  });

  final Product product;

  /// `د.أ` / `JOD`
  final String currency;
  final String addToCartLabel;

  /// Accessibility label of the heart button.
  final String favoriteLabel;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onAddToCart;

  String _money(double amount) => '${formatPrice(amount)} $currency';

  @override
  Widget build(BuildContext context) {
    final oldPrice = product.oldPrice;
    final size = product.sizeLabel;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 160 / 210,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  foregroundDecoration: BoxDecoration(
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: AppNetworkImage(url: product.imageUrl),
                ),
                PositionedDirectional(
                  top: 8.r,
                  end: 8.r,
                  child: _FavoriteButton(
                    label: favoriteLabel,
                    selected: isFavorite,
                    onTap: onFavorite,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            product.categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textXsRegular.copyWith(
              color: AppColors.textLabel,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textMdRegular.copyWith(
              color: AppColors.textDefault,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            size ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 8.w,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _money(product.finalPrice),
                style: AppTextStyles.textSmBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (oldPrice != null)
                Text(
                  _money(oldPrice),
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 32.h,
            child: FilledButton(
              onPressed: onAddToCart,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.symmetric(horizontal: 9.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                textStyle: AppTextStyles.textXsBold,
              ),
              child: Text(addToCartLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 32.r,
          height: 32.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: selected
              ? Icon(Icons.favorite, size: 20.r, color: AppColors.error)
              : SvgPicture.asset(
                  'assets/icons/home/heart.svg',
                  width: 24.r,
                  height: 24.r,
                ),
        ),
      ),
    );
  }
}
