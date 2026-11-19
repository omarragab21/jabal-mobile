import '../repositories/cart_repository.dart';

/// Changes the quantity of a product already in the cart.
class UpdateCartItem {
  const UpdateCartItem(this._repository);
  final CartRepository _repository;

  Future<void> call(int productId, int quantity) =>
      _repository.setItemQuantity(productId, quantity);
}
