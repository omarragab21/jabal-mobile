import '../repositories/cart_repository.dart';

class AddToCart {
  const AddToCart(this._repository);
  final CartRepository _repository;

  Future<void> call(int productId, {int quantity = 1}) =>
      _repository.addItem(productId, quantity: quantity);
}
