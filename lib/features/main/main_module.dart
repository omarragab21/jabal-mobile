import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/router/app_routes.dart';
import '../account/account_module.dart';
import '../address/address_module.dart';
import '../cart/cart_module.dart';
import '../checkout/checkout_module.dart';
import '../categories/categories_module.dart';
import '../home/home_module.dart';
import '../home/presentation/pages/category_args.dart';
import '../orders/orders_module.dart';
import '../search/search_module.dart';
import '../product_details/presentation/product_details_args.dart';
import '../home/domain/entities/product.dart';
import 'domain/entities/main_tab.dart';
import 'presentation/cubit/main_cubit.dart';
import 'presentation/pages/main_shell.dart';

/// Wires the main screen (bottom navigation) with every tab feature. Order of
/// the pages must match `MainTab`: home, categories, cart, orders, account.
class MainModule {
  MainModule({
    required this.home,
    required this.categories,
    required this.cart,
    required this.orders,
    required this.account,
    required this.address,
    required this.checkout,
    required this.search,
  });

  final HomeModule home;
  final CategoriesModule categories;
  final CartModule cart;
  final OrdersModule orders;
  final AccountModule account;
  final AddressModule address;
  final CheckoutModule checkout;
  final SearchModule search;

  final StreamController<MainTab> _tabRequests =
      StreamController<MainTab>.broadcast();

  /// Brings the main screen back (closing any pages on top of it) and
  /// selects the cart tab. Used by pages pushed above the tabs.
  void openCartTab(BuildContext context) => _openTab(context, MainTab.cart);

  /// Same, for the home tab (the order confirmation's "back to home").
  void openHomeTab(BuildContext context) => _openTab(context, MainTab.home);

  void _openTab(BuildContext context, MainTab tab) {
    Navigator.popUntil(
      context,
      (route) => route.settings.name == AppRoutes.main || route.isFirst,
    );
    _tabRequests.add(tab);
  }

  Widget page() => BlocProvider(
    create: (_) =>
        MainCubit(cart.watchCartCount, tabRequests: _tabRequests.stream),
    // Builder: the home shortcuts need the MainCubit provided just above.
    child: Builder(
      builder: (context) {
        void openProduct(BuildContext context, Product product) =>
            Navigator.pushNamed(
              context,
              AppRoutes.product,
              arguments: ProductDetailsArgs(productId: product.id),
            );
        void openSearch() => search.open(context, onOpenProduct: openProduct);
        void openCategories() =>
            context.read<MainCubit>().select(MainTab.categories);
        return MainShell(
          pages: [
            home.page(
              deliveryHeaderBuilder: address.header,
              onOpenCategories: openCategories,
              onOpenCategory: (category) => Navigator.pushNamed(
                context,
                AppRoutes.category,
                arguments: CategoryArgs(category.id),
              ),
              onOpenProduct: openProduct,
              onOpenSearch: openSearch,
            ),
            categories.page(
              onBack: () => context.read<MainCubit>().select(MainTab.home),
              onOpenSection: (section) => Navigator.pushNamed(
                context,
                AppRoutes.category,
                arguments: CategoryArgs(section.id),
              ),
              onOpenSearch: openSearch,
            ),
            cart.page(
              onDiscoverProducts: () =>
                  context.read<MainCubit>().select(MainTab.home),
              onEditItem: (ctx, item) => Navigator.pushNamed(
                ctx,
                AppRoutes.product,
                arguments: ProductDetailsArgs(
                  productId: item.product.id,
                  cartQuantity: item.quantity,
                ),
              ),
              onCheckout: (ctx) => checkout.open(ctx, onBackHome: openHomeTab),
            ),
            orders.page(
              onDiscoverProducts: () =>
                  context.read<MainCubit>().select(MainTab.home),
            ),
            account.page(),
          ],
        );
      },
    ),
  );
}
