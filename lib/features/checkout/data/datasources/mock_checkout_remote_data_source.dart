import '../../../../core/error/exceptions.dart';
import '../../domain/entities/checkout_entities.dart';
import '../models/checkout_models.dart';
import 'checkout_remote_data_source.dart';

/// Demo backend with API-shaped answers, after a short fake delay.
///
/// * Wallet balance 12.50 JOD, delivery fee 2.00 JOD.
/// * Codes (any letter case): `Jabal2026` takes 10% off, `PharmaJable` takes
///   5.00 JOD off (never more than the products cost).
class MockCheckoutRemoteDataSource implements CheckoutRemoteDataSource {
  MockCheckoutRemoteDataSource({
    this.latency = const Duration(milliseconds: 400),
  });

  final Duration latency;
  int _nextOrder = 8;

  Future<T> _respond<T>(T Function() build) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return build();
  }

  @override
  Future<CheckoutOptions> fetchOptions() => _respond(
    () => CheckoutModels.options(const {
      'wallet_balance': 12.5,
      'delivery_fee': 2,
      'apple_pay': true,
    }),
  );

  @override
  Future<PromoDiscount> validatePromo(String code, double subtotal) =>
      _respond(() {
        final discount = switch (code.toLowerCase()) {
          'jabal2026' => subtotal * 0.10,
          'pharmajable' => 5.0,
          _ => throw const ServerException(
            CheckoutErrorCodes.invalidPromo,
            statusCode: 422,
          ),
        };
        return CheckoutModels.promo({
          'code': code,
          'discount': discount > subtotal ? subtotal : discount,
        });
      });

  @override
  Future<PlacedOrder> placeOrder(PlaceOrderRequest request) => _respond(() {
    final id = _nextOrder++;
    final online =
        request.paymentMethod != 'cash' && request.pricing.payable > 0;
    return CheckoutModels.placedOrder({
      'id': '$id',
      'number': 'ORD-2026-${'$id'.padLeft(3, '0')}',
      'gateway_url': ?(online ? 'https://pay.drjabel.app/session/$id' : null),
    });
  });
}
