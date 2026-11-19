import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_links.dart';
import '../../../../core/sharing/share_link.dart';
import '../../../../core/sharing/share_target.dart';
import '../../../cart/domain/usecases/add_to_cart.dart';
import '../../../cart/domain/usecases/update_cart_item.dart';
import '../../../cart/domain/usecases/watch_cart_count.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/usecases/get_product_details.dart';
import '../product_details_args.dart';

enum ProductDetailsStatus { loading, ready, failed }

class ProductDetailsState extends Equatable {
  const ProductDetailsState({
    this.status = ProductDetailsStatus.loading,
    this.product,
    this.quantity = 1,
    this.imageIndex = 0,
    this.cartCount = 0,
    this.submitting = false,
  });

  final ProductDetailsStatus status;
  final ProductDetails? product;

  /// How many the customer is about to add (or the line is set to).
  final int quantity;

  /// The picture the carousel shows.
  final int imageIndex;
  final int cartCount;
  final bool submitting;

  /// Price of the chosen quantity.
  double get total => (product?.finalPrice ?? 0) * quantity;

  bool get canDecrement => quantity > 1;

  bool get canIncrement => product != null && quantity < product!.maxQuantity;

  ProductDetailsState copyWith({
    ProductDetailsStatus? status,
    ProductDetails? product,
    int? quantity,
    int? imageIndex,
    int? cartCount,
    bool? submitting,
  }) => ProductDetailsState(
    status: status ?? this.status,
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
    imageIndex: imageIndex ?? this.imageIndex,
    cartCount: cartCount ?? this.cartCount,
    submitting: submitting ?? this.submitting,
  );

  @override
  List<Object?> get props => [
    status,
    product,
    quantity,
    imageIndex,
    cartCount,
    submitting,
  ];
}

/// View model of a product's page: loads it, keeps the chosen quantity and
/// picture, and adds it to the cart (or updates the cart line) and shares it.
class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit({
    required this.args,
    required GetProductDetails getProductDetails,
    required AddToCart addToCart,
    required UpdateCartItem updateCartItem,
    required WatchCartCount watchCartCount,
    required ShareLink shareLink,
  }) : _getProductDetails = getProductDetails,
       _addToCart = addToCart,
       _updateCartItem = updateCartItem,
       _shareLink = shareLink,
       super(ProductDetailsState(quantity: args.cartQuantity ?? 1)) {
    _cartSub = watchCartCount().listen(
      (count) => emit(state.copyWith(cartCount: count)),
    );
  }

  final ProductDetailsArgs args;
  final GetProductDetails _getProductDetails;
  final AddToCart _addToCart;
  final UpdateCartItem _updateCartItem;
  final ShareLink _shareLink;
  late final StreamSubscription<int> _cartSub;

  Future<void> load(String languageCode) async {
    emit(state.copyWith(status: ProductDetailsStatus.loading));
    final result = await _getProductDetails(args.productId, languageCode);
    if (isClosed) return;
    result.when(
      success: (product) => emit(
        state.copyWith(
          status: ProductDetailsStatus.ready,
          product: product,
          // An edited line may exceed what is left in stock now.
          quantity: _clamp(state.quantity, product),
        ),
      ),
      failure: (_) => emit(state.copyWith(status: ProductDetailsStatus.failed)),
    );
  }

  static int _clamp(int quantity, ProductDetails product) {
    final max = product.maxQuantity;
    if (max < 1) return 1;
    return quantity > max ? max : quantity;
  }

  void increment() {
    if (state.canIncrement) emit(state.copyWith(quantity: state.quantity + 1));
  }

  void decrement() {
    if (state.canDecrement) emit(state.copyWith(quantity: state.quantity - 1));
  }

  void selectImage(int index) {
    if (index != state.imageIndex) emit(state.copyWith(imageIndex: index));
  }

  /// Adds to the cart, or updates the cart line when the page was opened to
  /// edit it. True when it worked.
  Future<bool> submit() async {
    final product = state.product;
    if (product == null || !product.inStock || state.submitting) return false;
    emit(state.copyWith(submitting: true));
    try {
      if (args.isUpdate) {
        await _updateCartItem(product.id, state.quantity);
      } else {
        await _addToCart(product.id, quantity: state.quantity);
      }
      return true;
    } on Object {
      return false;
    } finally {
      if (!isClosed) emit(state.copyWith(submitting: false));
    }
  }

  /// Sends the product's link to [target]; [message] is the text that goes
  /// with it (already translated).
  Future<ShareOutcome> share(ShareTarget target, String message) => _shareLink(
    target,
    message: message,
    link: AppLinks.product(args.productId),
  );

  @override
  Future<void> close() {
    _cartSub.cancel();
    return super.close();
  }
}
