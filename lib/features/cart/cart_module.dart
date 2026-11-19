import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/datasources/mock_cart_catalogue.dart';
import 'data/repositories/mock_cart_repository.dart';
import 'domain/entities/cart.dart';
import 'domain/repositories/cart_catalogue.dart';
import 'domain/repositories/cart_repository.dart';
import 'domain/usecases/add_to_cart.dart';
import 'domain/usecases/cart_use_cases.dart';
import 'domain/usecases/update_cart_item.dart';
import 'domain/usecases/watch_cart_count.dart';
import 'presentation/cubit/cart_cubit.dart';
import 'presentation/pages/cart_page.dart';

/// Wires the cart feature. Pass a real [CartRepository] / [CartCatalogue] to
/// replace the mocks.
class CartModule {
  CartModule({
    CartRepository? repository,
    CartCatalogue? catalogue,
    Duration latency = const Duration(milliseconds: 200),
  }) : _repository = repository ?? MockCartRepository(),
       _catalogue = catalogue ?? MockCartCatalogue(latency: latency);

  final CartRepository _repository;
  final CartCatalogue _catalogue;

  /// Used by the tab bar badge.
  WatchCartCount get watchCartCount => WatchCartCount(_repository);

  /// Used by product cards.
  AddToCart get addToCart => AddToCart(_repository);

  /// Used by the product page when editing a cart line.
  UpdateCartItem get updateCartItem => UpdateCartItem(_repository);

  /// The rows, live (checkout reads the cart through these).
  WatchCartLines get watchCartLines => WatchCartLines(_repository);

  /// The rows, once.
  GetCartLines get getCartLines => GetCartLines(_repository);

  /// Joins rows with their products.
  GetCart get getCart => GetCart(_catalogue);

  /// Empties the cart once an order is placed.
  ClearCart get clearCart => ClearCart(_repository);

  /// The cart tab. [onDiscoverProducts] leads to the shop, [onEditItem] opens
  /// a row's product to change it, [onCheckout] continues to checkout.
  Widget page({
    required VoidCallback onDiscoverProducts,
    required void Function(BuildContext context, CartItem item) onEditItem,
    required void Function(BuildContext context) onCheckout,
  }) => BlocProvider(
    create: (_) => CartCubit(
      watchLines: watchCartLines,
      getCart: getCart,
      updateItem: updateCartItem,
      removeItem: RemoveFromCart(_repository),
    ),
    child: CartPage(
      onDiscoverProducts: onDiscoverProducts,
      onEditItem: onEditItem,
      onCheckout: onCheckout,
    ),
  );
}
