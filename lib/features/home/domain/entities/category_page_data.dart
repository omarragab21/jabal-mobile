import 'package:equatable/equatable.dart';

import 'product.dart';
import 'product_category.dart';

/// What a category page shows: the category (its sub-categories become the
/// chips) and the products of the category and all its sub-categories.
class CategoryPageData extends Equatable {
  const CategoryPageData({required this.category, required this.products});

  final ProductCategory category;
  final List<Product> products;

  @override
  List<Object?> get props => [category, products];
}
