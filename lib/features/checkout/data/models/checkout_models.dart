import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/checkout_entities.dart';

/// Parses the API's checkout JSON into domain entities.
abstract final class CheckoutModels {
  static CheckoutOptions options(Map<String, dynamic> json) => CheckoutOptions(
    walletBalance: JsonReader.decimal(json['wallet_balance']),
    deliveryFee: JsonReader.decimal(json['delivery_fee']),
    applePayAvailable: JsonReader.boolean(json['apple_pay'], true),
  );

  static PromoDiscount promo(Map<String, dynamic> json) => PromoDiscount(
    code: JsonReader.string(json['code']),
    amount: JsonReader.decimal(json['discount']),
  );

  static PlacedOrder placedOrder(Map<String, dynamic> json) => PlacedOrder(
    id: JsonReader.string(json['id']),
    number: JsonReader.string(json['number']),
    gatewayUrl: JsonReader.stringOrNull(json['gateway_url']),
  );
}
