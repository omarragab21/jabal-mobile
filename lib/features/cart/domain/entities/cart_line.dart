import 'package:equatable/equatable.dart';

/// What is stored of a cart row: a product and how many of it.
class CartLine extends Equatable {
  const CartLine({required this.productId, required this.quantity})
    : assert(quantity > 0);

  final int productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
}
