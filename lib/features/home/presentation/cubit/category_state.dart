import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/category_page_data.dart';
import '../../domain/entities/product.dart';

enum CategoryStatus { loading, ready, failed }

class CategoryState extends Equatable {
  const CategoryState({
    this.status = CategoryStatus.loading,
    this.data,
    this.failure,
    this.cartCount = 0,
    this.selectedSubCategoryId,
  });

  final CategoryStatus status;

  /// Null until the first load succeeds.
  final CategoryPageData? data;
  final Failure? failure;

  /// Shown on the cart icon in the header.
  final int cartCount;

  /// The sub-category chip that filters the grid; null = "all".
  final int? selectedSubCategoryId;

  /// The products the grid shows: all of them, or those of the selected
  /// sub-category.
  List<Product> get visibleProducts {
    final data = this.data;
    if (data == null) return const [];
    final selected = selectedSubCategoryId;
    if (selected == null) return data.products;
    final ids = data.category.find(selected)?.allIds ?? {selected};
    return [
      for (final product in data.products)
        if (ids.contains(product.categoryId)) product,
    ];
  }

  CategoryState copyWith({
    CategoryStatus? status,
    CategoryPageData? data,
    Failure? Function()? failure,
    int? cartCount,
    int? Function()? selectedSubCategoryId,
  }) => CategoryState(
    status: status ?? this.status,
    data: data ?? this.data,
    failure: failure != null ? failure() : this.failure,
    cartCount: cartCount ?? this.cartCount,
    selectedSubCategoryId: selectedSubCategoryId != null
        ? selectedSubCategoryId()
        : this.selectedSubCategoryId,
  );

  @override
  List<Object?> get props => [
    status,
    data,
    failure,
    cartCount,
    selectedSubCategoryId,
  ];
}
