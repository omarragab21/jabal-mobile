import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';

/// The products the customer hearted, shared by every page that lists
/// products so a heart looks the same everywhere. Kept for the session.
class FavoritesCubit extends Cubit<Set<int>> {
  FavoritesCubit() : super(const {});

  bool isFavorite(Product product) => state.contains(product.id);

  void toggle(Product product) => toggleId(product.id);

  /// For pages that know a product only by its id (the product details).
  void toggleId(int productId) {
    final ids = {...state};
    if (!ids.remove(productId)) ids.add(productId);
    emit(ids);
  }
}
