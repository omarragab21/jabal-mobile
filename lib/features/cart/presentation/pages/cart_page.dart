import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_tab_page.dart';
import '../../domain/entities/cart.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/cart_empty_view.dart';
import '../widgets/cart_item_tile.dart';

/// The cart tab: how many products, "add more", the rows, and the subtotal
/// with the button that continues to checkout. Empty, it invites to the
/// products.
class CartPage extends StatefulWidget {
  const CartPage({
    super.key,
    required this.onDiscoverProducts,
    required this.onEditItem,
    required this.onCheckout,
  });

  /// "Add more" and the empty cart's button.
  final VoidCallback onDiscoverProducts;

  /// The pencil on a row: open its product to change the quantity.
  final void Function(BuildContext context, CartItem item) onEditItem;

  /// "Continue to checkout".
  final void Function(BuildContext context) onCheckout;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? _languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = context.locale.languageCode;
    if (code != _languageCode) {
      _languageCode = code;
      context.read<CartCubit>().start(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) => AppTabPage(
        title: 'nav.cart'.tr(context: context),
        body: ColoredBox(
          color: AppColors.backgroundBody,
          child: switch (state.status) {
            CartStatus.loading => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            CartStatus.failed => Center(
              child: TextButton(
                onPressed: cubit.retry,
                child: Text('home.retry'.tr(context: context)),
              ),
            ),
            CartStatus.ready when state.cart.isEmpty => CartEmptyView(
              onDiscover: widget.onDiscoverProducts,
            ),
            CartStatus.ready => _Filled(
              cart: state.cart,
              cubit: cubit,
              page: widget,
            ),
          },
        ),
      ),
    );
  }
}

class _Filled extends StatelessWidget {
  const _Filled({required this.cart, required this.cubit, required this.page});

  final Cart cart;
  final CartCubit cubit;
  final CartPage page;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'cart.$key'.tr(context: context);
    final currency = 'home.currency'.tr(context: context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.r),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t(
                        'items_count',
                      ).replaceAll('{count}', '${cart.itemsCount}'),
                      style: AppTextStyles.textMdBold.copyWith(
                        color: AppColors.textDefault,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: page.onDiscoverProducts,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDefault,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: Size(0, 40.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      textStyle: AppTextStyles.textMdRegular,
                    ),
                    child: Text(t('add_more')),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              for (final item in cart.items) ...[
                CartItemTile(
                  key: ValueKey('cart-item-${item.product.id}'),
                  item: item,
                  onEdit: () => page.onEditItem(context, item),
                  onIncrement:
                      item.product.stock > 0 &&
                          item.quantity >= item.product.stock
                      ? null
                      : () => cubit.increment(item),
                  onDecrement: () => cubit.decrement(item),
                ),
                SizedBox(height: 24.h),
              ],
            ],
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.backgroundBody,
            border: Border(top: BorderSide(color: AppColors.cardBorder)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t('subtotal'),
                        style: AppTextStyles.textMdBold.copyWith(
                          color: AppColors.textDefault,
                        ),
                      ),
                    ),
                    Text(
                      '${cart.subtotal.toStringAsFixed(2)} $currency',
                      key: const ValueKey('cart-subtotal'),
                      style: AppTextStyles.textMdBold.copyWith(
                        color: AppColors.textDefault,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                AppButton(
                  label: t('checkout'),
                  onPressed: () => page.onCheckout(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
