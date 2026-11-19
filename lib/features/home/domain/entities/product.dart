import 'package:equatable/equatable.dart';

/// One value of a product option, e.g. `50 مل` or a colour with its hex.
class ProductAttributeValue extends Equatable {
  const ProductAttributeValue({
    required this.id,
    required this.name,
    this.colorHex,
  });

  final int id;
  final String name;

  /// Set only for colour options (`#ab1717`).
  final String? colorHex;

  bool get isColor => colorHex != null;

  @override
  List<Object?> get props => [id, name, colorHex];
}

/// A product option group (size, colour, ...) with its values.
class ProductAttribute extends Equatable {
  const ProductAttribute({required this.name, required this.values});

  final String name;
  final List<ProductAttributeValue> values;

  @override
  List<Object?> get props => [name, values];
}

/// A product as the catalogue lists it. Texts are already in the language the
/// data was requested in.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.finalPrice,
    this.imageUrl,
    this.attributes = const [],
    this.stock = 0,
    this.isActive = true,
    this.isFeatured = false,
  }) : assert(price >= 0 && finalPrice >= 0);

  final int id;
  final String name;
  final int categoryId;
  final String categoryName;

  /// List price before any discount.
  final double price;

  /// What the customer pays.
  final double finalPrice;
  final String? imageUrl;
  final List<ProductAttribute> attributes;
  final int stock;
  final bool isActive;
  final bool isFeatured;

  bool get hasDiscount => finalPrice < price;

  /// The crossed-out price; null when there is no discount.
  double? get oldPrice => hasDiscount ? price : null;

  /// Whole percent saved (15 for 15%), 0 without a discount.
  int get discountPercent =>
      hasDiscount ? ((price - finalPrice) / price * 100).round() : 0;

  bool get inStock => isActive && stock > 0;

  /// Short pack/size text under the name (`30 مل`): the first value of the
  /// first option that is not a colour.
  String? get sizeLabel {
    for (final attribute in attributes) {
      for (final value in attribute.values) {
        if (!value.isColor) return value.name;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    categoryId,
    categoryName,
    price,
    finalPrice,
    imageUrl,
    attributes,
    stock,
    isActive,
    isFeatured,
  ];
}
