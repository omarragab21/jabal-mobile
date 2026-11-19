import '../../../../core/utils/result.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/domain/usecases/cart_use_cases.dart';
import '../entities/checkout_entities.dart';
import '../repositories/checkout_repository.dart';

/// The cart as it is right now.
class GetCurrentCart {
  const GetCurrentCart(this._getLines, this._getCart);

  final GetCartLines _getLines;
  final GetCart _getCart;

  Future<Result<Cart>> call(String languageCode) async =>
      _getCart(await _getLines(), languageCode);
}

class GetCheckoutOptions {
  const GetCheckoutOptions(this._repository);
  final CheckoutRepository _repository;

  Future<Result<CheckoutOptions>> call() => _repository.getOptions();
}

class ApplyPromoCode {
  const ApplyPromoCode(this._repository);
  final CheckoutRepository _repository;

  Future<Result<PromoDiscount>> call(String code, double subtotal) =>
      _repository.validatePromo(code.trim(), subtotal);
}

class PlaceOrder {
  const PlaceOrder(this._repository);
  final CheckoutRepository _repository;

  Future<Result<PlacedOrder>> call(PlaceOrderRequest request) =>
      _repository.placeOrder(request);
}
