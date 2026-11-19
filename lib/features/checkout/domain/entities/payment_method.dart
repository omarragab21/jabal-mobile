import 'package:equatable/equatable.dart';

import '../../../payment_cards/domain/entities/payment_card.dart';

/// How the customer pays for the order.
sealed class PaymentMethod extends Equatable {
  const PaymentMethod();

  /// Paid in a gateway page (cards, Apple Pay) rather than in hand.
  bool get isOnline => this is! CashPayment;

  @override
  List<Object?> get props => const [];
}

/// Cash to the courier.
class CashPayment extends PaymentMethod {
  const CashPayment();
}

class ApplePayPayment extends PaymentMethod {
  const ApplePayPayment();
}

/// One of the customer's saved cards.
class CardPayment extends PaymentMethod {
  const CardPayment(this.card);

  final PaymentCard card;

  @override
  List<Object?> get props => [card];
}
