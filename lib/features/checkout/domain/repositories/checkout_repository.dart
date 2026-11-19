import '../../../../core/utils/result.dart';
import '../entities/checkout_entities.dart';

abstract interface class CheckoutRepository {
  Future<Result<CheckoutOptions>> getOptions();

  /// Checks a discount [code] against a cart worth [subtotal]; an
  /// `InvalidPromoCodeFailure` when it cannot be used.
  Future<Result<PromoDiscount>> validatePromo(String code, double subtotal);

  Future<Result<PlacedOrder>> placeOrder(PlaceOrderRequest request);
}
