import '../../../cart/domain/entities/cart.dart';
import '../entities/checkout_entities.dart';

/// All the order's arithmetic in one place, so the page only shows numbers.
abstract final class PricingCalculator {
  /// Prices [cart] with an optional [promo], the [deliveryFee], and the
  /// wallet when [useWallet] (it pays as much as it holds, never more than
  /// what is due).
  static CheckoutPricing calculate({
    required Cart cart,
    required double deliveryFee,
    PromoDiscount? promo,
    bool useWallet = false,
    double walletBalance = 0,
  }) {
    final subtotal = cart.subtotal;
    // A code never takes off more than the products cost.
    final discount = _clamp(promo?.amount ?? 0, 0, subtotal);
    final total = subtotal - discount + (cart.isEmpty ? 0 : deliveryFee);
    final wallet = useWallet ? _clamp(walletBalance, 0, total) : 0.0;
    return CheckoutPricing(
      subtotal: subtotal,
      savings: cart.savings,
      promoDiscount: discount,
      deliveryFee: cart.isEmpty ? 0 : deliveryFee,
      walletUsed: wallet,
      total: total,
    );
  }

  static double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);
}
