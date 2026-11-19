import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/domain/usecases/add_to_cart.dart';
import '../../../cart/domain/usecases/watch_cart_count.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_category_page.dart';
import 'category_state.dart';

/// View model of one category / section page.
class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit({
    required this.categoryId,
    required GetCategoryPage getCategoryPage,
    required AddToCart addToCart,
    required WatchCartCount watchCartCount,
  }) : _getCategoryPage = getCategoryPage,
       _addToCart = addToCart,
       super(const CategoryState()) {
    _cartSub = watchCartCount().listen(
      (count) => emit(state.copyWith(cartCount: count)),
    );
  }

  final int categoryId;
  final GetCategoryPage _getCategoryPage;
  final AddToCart _addToCart;
  late final StreamSubscription<int> _cartSub;

  Future<void> load(String languageCode) async {
    // A reload (language change) starts from "all" again.
    emit(
      state.copyWith(
        status: CategoryStatus.loading,
        failure: () => null,
        selectedSubCategoryId: () => null,
      ),
    );
    final result = await _getCategoryPage(categoryId, languageCode);
    if (isClosed) return;
    result.when(
      success: (data) => emit(
        state.copyWith(
          status: CategoryStatus.ready,
          data: data,
          failure: () => null,
        ),
      ),
      failure: (failure) => emit(
        state.copyWith(status: CategoryStatus.failed, failure: () => failure),
      ),
    );
  }

  /// Filters the grid to a sub-category; null shows everything again.
  void selectSubCategory(int? id) {
    if (id == state.selectedSubCategoryId) return;
    emit(state.copyWith(selectedSubCategoryId: () => id));
  }

  Future<void> addToCart(Product product) => _addToCart(product.id);

  @override
  Future<void> close() {
    _cartSub.cancel();
    return super.close();
  }
}
