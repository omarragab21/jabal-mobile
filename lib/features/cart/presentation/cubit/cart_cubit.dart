import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/usecases/cart_use_cases.dart';
import '../../domain/usecases/update_cart_item.dart';

enum CartStatus { loading, ready, failed }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.loading,
    this.cart = const Cart.empty(),
  });

  final CartStatus status;
  final Cart cart;

  @override
  List<Object?> get props => [status, cart];
}

/// View model of the cart tab: keeps the cart in step with its rows and
/// changes quantities.
class CartCubit extends Cubit<CartState> {
  CartCubit({
    required WatchCartLines watchLines,
    required GetCart getCart,
    required UpdateCartItem updateItem,
    required RemoveFromCart removeItem,
  }) : _watchLines = watchLines,
       _getCart = getCart,
       _updateItem = updateItem,
       _removeItem = removeItem,
       super(const CartState());

  final WatchCartLines _watchLines;
  final GetCart _getCart;
  final UpdateCartItem _updateItem;
  final RemoveFromCart _removeItem;

  StreamSubscription<List<CartLine>>? _subscription;
  List<CartLine> _lines = const [];
  String _languageCode = 'ar';

  /// A newer request makes an older, slower one irrelevant.
  int _request = 0;

  /// Starts following the cart in [languageCode]; calling it again (the
  /// language changed) reloads the product texts.
  void start(String languageCode) {
    _languageCode = languageCode;
    if (_subscription == null) {
      _subscription = _watchLines().listen((lines) {
        _lines = lines;
        unawaited(_refresh());
      });
    } else {
      unawaited(_refresh());
    }
  }

  Future<void> retry() {
    emit(const CartState());
    return _refresh();
  }

  Future<void> _refresh() async {
    final request = ++_request;
    final result = await _getCart(_lines, _languageCode);
    if (isClosed || request != _request) return;
    result.when(
      success: (cart) => emit(CartState(status: CartStatus.ready, cart: cart)),
      failure: (_) =>
          emit(CartState(status: CartStatus.failed, cart: state.cart)),
    );
  }

  /// One more of [item], up to what is in stock.
  Future<void> increment(CartItem item) {
    final stock = item.product.stock;
    if (stock > 0 && item.quantity >= stock) return Future.value();
    return _updateItem(item.product.id, item.quantity + 1);
  }

  /// One less of [item]; the last one takes the row out of the cart.
  Future<void> decrement(CartItem item) => item.quantity > 1
      ? _updateItem(item.product.id, item.quantity - 1)
      : _removeItem(item.product.id);

  Future<void> remove(CartItem item) => _removeItem(item.product.id);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
