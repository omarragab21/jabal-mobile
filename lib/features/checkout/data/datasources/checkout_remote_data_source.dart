import '../../domain/entities/checkout_entities.dart';

/// Where checkout talks to the server. [MockCheckoutRemoteDataSource] stands
/// in until the API exists.
abstract interface class CheckoutRemoteDataSource {
  Future<CheckoutOptions> fetchOptions();

  /// Throws a `ServerException` with [CheckoutErrorCodes.invalidPromo] when
  /// the code cannot be used.
  Future<PromoDiscount> validatePromo(String code, double subtotal);

  Future<PlacedOrder> placeOrder(PlaceOrderRequest request);
}

/// Error codes the server answers with.
abstract final class CheckoutErrorCodes {
  static const String invalidPromo = 'invalid_promo_code';
}
