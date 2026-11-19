import '../../../../core/utils/result.dart';
import '../entities/cart.dart';
import '../entities/cart_line.dart';
import '../repositories/cart_catalogue.dart';
import '../repositories/cart_repository.dart';

/// The cart's rows, live.
class WatchCartLines {
  const WatchCartLines(this._repository);
  final CartRepository _repository;

  Stream<List<CartLine>> call() => _repository.watchLines();
}

/// The cart's rows as they are now.
class GetCartLines {
  const GetCartLines(this._repository);
  final CartRepository _repository;

  Future<List<CartLine>> call() => _repository.getLines();
}

/// Joins cart [lines] with their products. A row whose product no longer
/// exists is left out.
class GetCart {
  const GetCart(this._catalogue);
  final CartCatalogue _catalogue;

  Future<Result<Cart>> call(List<CartLine> lines, String languageCode) async {
    if (lines.isEmpty) return const Success(Cart.empty());
    final result = await _catalogue.productsByIds([
      for (final line in lines) line.productId,
    ], languageCode);
    return result.when(
      success: (products) {
        final byId = {for (final p in products) p.id: p};
        return Success(
          Cart([
            for (final line in lines)
              if (byId[line.productId] case final product?)
                CartItem(product: product, quantity: line.quantity),
          ]),
        );
      },
      failure: Err.new,
    );
  }
}

class RemoveFromCart {
  const RemoveFromCart(this._repository);
  final CartRepository _repository;

  Future<void> call(int productId) => _repository.removeItem(productId);
}

class ClearCart {
  const ClearCart(this._repository);
  final CartRepository _repository;

  Future<void> call() => _repository.clear();
}
