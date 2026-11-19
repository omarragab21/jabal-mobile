import 'package:equatable/equatable.dart';

import 'product.dart';
import 'product_category.dart';

/// A titled row of products on the home page: one category and its products.
class HomeSection extends Equatable {
  const HomeSection({required this.category, required this.products});

  final ProductCategory category;
  final List<Product> products;

  String get title => category.name;

  @override
  List<Object?> get props => [category, products];
}
