import 'package:equatable/equatable.dart';

/// A product as its own page shows it: every picture, the description and how
/// many people are looking at it. Texts are already in the language the data
/// was requested in.
class ProductDetails extends Equatable {
  const ProductDetails({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.finalPrice,
    required this.description,
    this.images = const [],
    this.viewersNow = 0,
    this.stock = 0,
    this.isActive = true,
  }) : assert(price >= 0 && finalPrice >= 0);

  final int id;
  final String name;
  final int categoryId;
  final String categoryName;

  /// List price before any discount.
  final double price;

  /// What the customer pays for one.
  final double finalPrice;
  final String description;

  /// Picture addresses, the main one first.
  final List<String> images;

  /// People looking at this product right now.
  final int viewersNow;
  final int stock;
  final bool isActive;

  bool get hasDiscount => finalPrice < price;

  /// The crossed-out price; null when there is no discount.
  double? get oldPrice => hasDiscount ? price : null;

  bool get inStock => isActive && stock > 0;

  /// The most that can be ordered at once.
  int get maxQuantity => inStock ? stock : 0;

  @override
  List<Object?> get props => [
    id,
    name,
    categoryId,
    categoryName,
    price,
    finalPrice,
    description,
    images,
    viewersNow,
    stock,
    isActive,
  ];
}
