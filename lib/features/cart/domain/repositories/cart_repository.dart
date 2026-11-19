import '../entities/cart_line.dart';

/// Cart data the rest of the app needs. Implementations can be a mock, a
/// local store or an API.
abstract interface class CartRepository {
  /// Number of pieces in the cart; emits again whenever it changes.
  Stream<int> watchItemCount();

  /// The rows of the cart, oldest first; emits again whenever they change.
  Stream<List<CartLine>> watchLines();

  /// The rows of the cart right now (a one-time read).
  Future<List<CartLine>> getLines();

  /// Adds [quantity] of a product to the cart.
  Future<void> addItem(int productId, {int quantity = 1});

  /// Sets a product's quantity in the cart to exactly [quantity] (adding the
  /// product when it is not there yet).
  Future<void> setItemQuantity(int productId, int quantity);

  /// Takes a product out of the cart.
  Future<void> removeItem(int productId);

  /// Empties the cart (after the order was placed).
  Future<void> clear();
}
