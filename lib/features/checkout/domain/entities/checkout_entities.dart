import 'package:equatable/equatable.dart';

/// What the checkout page needs from the server before it can show prices.
class CheckoutOptions extends Equatable {
  const CheckoutOptions({
    required this.walletBalance,
    required this.deliveryFee,
    this.applePayAvailable = true,
  });

  /// Money the customer holds in their wallet.
  final double walletBalance;
  final double deliveryFee;
  final bool applePayAvailable;

  @override
  List<Object?> get props => [walletBalance, deliveryFee, applePayAvailable];
}

/// A discount code that was accepted: how much it takes off.
class PromoDiscount extends Equatable {
  const PromoDiscount({required this.code, required this.amount});

  final String code;
  final double amount;

  @override
  List<Object?> get props => [code, amount];
}

/// Every amount of the order, from the cart to what is paid now.
class CheckoutPricing extends Equatable {
  const CheckoutPricing({
    required this.subtotal,
    required this.savings,
    required this.promoDiscount,
    required this.deliveryFee,
    required this.walletUsed,
    required this.total,
  });

  /// The products, after their own discounts.
  final double subtotal;

  /// What the products' own discounts saved (informational).
  final double savings;
  final double promoDiscount;
  final double deliveryFee;

  /// Taken from the wallet.
  final double walletUsed;

  /// The order's value: subtotal - promo + delivery.
  final double total;

  /// What is still to pay after the wallet.
  double get payable => total - walletUsed;

  @override
  List<Object?> get props => [
    subtotal,
    savings,
    promoDiscount,
    deliveryFee,
    walletUsed,
    total,
  ];
}

/// One row of the order to place.
class OrderLineRequest extends Equatable {
  const OrderLineRequest({required this.productId, required this.quantity});

  final int productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
}

/// The order the customer confirmed.
class PlaceOrderRequest extends Equatable {
  const PlaceOrderRequest({
    required this.lines,
    required this.addressId,
    required this.addressLabel,
    required this.addressDetails,
    required this.paymentMethod,
    required this.pricing,
    this.promoCode,
    this.useWallet = false,
  });

  final List<OrderLineRequest> lines;

  /// Set when the place is one of the saved addresses.
  final String? addressId;
  final String addressLabel;
  final String addressDetails;
  final String paymentMethod;
  final CheckoutPricing pricing;
  final String? promoCode;
  final bool useWallet;

  @override
  List<Object?> get props => [
    lines,
    addressId,
    addressLabel,
    addressDetails,
    paymentMethod,
    pricing,
    promoCode,
    useWallet,
  ];
}

/// An order the server accepted.
class PlacedOrder extends Equatable {
  const PlacedOrder({required this.id, required this.number, this.gatewayUrl});

  final String id;

  /// What the customer sees, `ORD-2026-010`.
  final String number;

  /// Set when the payment continues in the gateway page.
  final String? gatewayUrl;

  bool get needsGateway => gatewayUrl != null;

  @override
  List<Object?> get props => [id, number, gatewayUrl];
}
