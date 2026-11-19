import 'package:equatable/equatable.dart';

/// A product as the cart shows it. Texts are in the language it was
/// requested in.
class CartProduct extends Equatable {
  const CartProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.finalPrice,
    this.imageUrl,
    this.sizeLabel,
    this.stock = 0,
  }) : assert(price >= 0 && finalPrice >= 0);

  final int id;
  final String name;

  /// List price before any discount.
  final double price;

  /// What the customer pays for one.
  final double finalPrice;
  final String? imageUrl;

  /// Pack size under the name (`20 قرصًا`).
  final String? sizeLabel;
  final int stock;

  bool get hasDiscount => finalPrice < price;

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    finalPrice,
    imageUrl,
    sizeLabel,
    stock,
  ];
}

/// A cart row with its product: [quantity] of [product].
class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity})
    : assert(quantity > 0);

  final CartProduct product;
  final int quantity;

  double get total => product.finalPrice * quantity;

  /// What the discount saves on this row.
  double get savings => (product.price - product.finalPrice) * quantity;

  @override
  List<Object?> get props => [product, quantity];
}

/// Everything in the cart, with the totals the pages show.
class Cart extends Equatable {
  const Cart(this.items);

  const Cart.empty() : items = const [];

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  /// Pieces in the cart: two of one product and one of another are three.
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// What the products cost after their own discounts.
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  /// What the products' own discounts saved.
  double get savings => items.fold(0.0, (sum, item) => sum + item.savings);

  @override
  List<Object?> get props => [items];
}
