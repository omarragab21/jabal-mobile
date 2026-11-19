import 'package:equatable/equatable.dart';

class ProductCategory extends Equatable {
  const ProductCategory({
    required this.id,
    required this.name,
    this.imageUrl,
    this.parentId,
    this.sortOrder = 0,
    this.subCategories = const [],
  });

  final int id;
  final String name;
  final String? imageUrl;
  final int? parentId;
  final int sortOrder;

  /// Direct children, in display order; empty for a leaf.
  final List<ProductCategory> subCategories;

  bool get isRoot => parentId == null;
  bool get hasSubCategories => subCategories.isNotEmpty;

  /// This category's id followed by every descendant id: the products of a
  /// category are the products of all of these.
  Set<int> get allIds => {
    id,
    for (final child in subCategories) ...child.allIds,
  };

  /// This category or one of its descendants with [categoryId]; null when
  /// it is not in this branch.
  ProductCategory? find(int categoryId) {
    if (id == categoryId) return this;
    for (final child in subCategories) {
      final found = child.find(categoryId);
      if (found != null) return found;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    parentId,
    sortOrder,
    subCategories,
  ];
}
