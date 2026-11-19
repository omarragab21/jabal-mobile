import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/count_badge.dart';
import '../../domain/entities/product_category.dart';
import '../cubit/category_cubit.dart';
import '../cubit/category_state.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_tile.dart';

/// A section page: header with the cart, the sub-section chips (when the
/// section has any) and the product grid. A chip filters the grid in place.
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.onOpenCart, this.onOpenProduct});

  /// The cart icon was tapped; gets this page's context to navigate with.
  final ValueChanged<BuildContext> onOpenCart;

  /// A product card was tapped.
  final ProductOpener? onOpenProduct;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String? _languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = context.locale.languageCode;
    if (code != _languageCode) {
      _languageCode = code;
      context.read<CategoryCubit>().load(code);
    }
  }

  String _t(String key) => 'home.$key'.tr(context: context);

  Widget _message(String text, {String? actionLabel, VoidCallback? onAction}) =>
      Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (actionLabel != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel,
                    style: AppTextStyles.textMdBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryCubit>();
    return Scaffold(
      backgroundColor: AppColors.backgroundBody,
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          final data = state.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // white from the top of the screen, status bar included
              ColoredBox(
                color: AppColors.white,
                child: SafeArea(
                  bottom: false,
                  child: AppPageHeader(
                    title: data?.category.name ?? '',
                    trailing: _CartButton(
                      count: state.cartCount,
                      label: 'nav.cart'.tr(context: context),
                      onTap: () => widget.onOpenCart(context),
                    ),
                  ),
                ),
              ),
              if (data != null && data.category.hasSubCategories) ...[
                SizedBox(height: 16.h),
                CategoryChips(
                  allLabel: _t('all'),
                  labels: [for (final c in data.category.subCategories) c.name],
                  selectedIndex: _indexOf(state, data.category.subCategories),
                  onSelected: (i) => cubit.selectSubCategory(
                    i == 0 ? null : data.category.subCategories[i - 1].id,
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              Expanded(child: _body(state, cubit)),
            ],
          );
        },
      ),
    );
  }

  /// 0 for "all", else the position of the selected chip.
  int _indexOf(CategoryState state, List<ProductCategory> subs) {
    final selected = state.selectedSubCategoryId;
    if (selected == null) return 0;
    final index = subs.indexWhere((c) => c.id == selected);
    return index < 0 ? 0 : index + 1;
  }

  Widget _body(CategoryState state, CategoryCubit cubit) {
    if (state.status == CategoryStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    final data = state.data;
    if (state.status == CategoryStatus.failed || data == null) {
      return _message(
        _t('error'),
        actionLabel: _t('retry'),
        onAction: () => cubit.load(_languageCode ?? 'ar'),
      );
    }
    final products = state.visibleProducts;
    if (products.isEmpty) return _message(_t('empty_category'));
    return ProductGrid(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      cards: [
        for (final product in products)
          ProductTile(
            key: ValueKey('product-${product.id}'),
            product: product,
            onTap: () => widget.onOpenProduct?.call(context, product),
            onAddToCart: () async {
              await cubit.addToCart(product);
              if (mounted) showAddedToCart(context, product);
            },
          ),
      ],
    );
  }
}

/// Cart icon with the item count, at the end of the header.
class _CartButton extends StatelessWidget {
  const _CartButton({
    required this.count,
    required this.label,
    required this.onTap,
  });

  final int count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 24.r,
        child: SizedBox(
          width: 32.r,
          height: 32.r,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/home/cart_bag.svg',
                width: 24.r,
                height: 24.r,
              ),
              // on the icon's outer top corner (left in RTL, right in LTR)
              PositionedDirectional(
                top: -6.r,
                end: -4.r,
                child: CountBadge(count: count),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
