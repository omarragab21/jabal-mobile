import 'package:equatable/equatable.dart';

enum CardBrand {
  visa,
  mastercard,
  other;

  /// The brand a card number belongs to (Visa starts with 4, Mastercard with
  /// 51-55 or 2221-2720).
  static CardBrand of(String digits) {
    if (digits.startsWith('4')) return visa;
    if (digits.length >= 2) {
      final two = int.tryParse(digits.substring(0, 2)) ?? 0;
      if (two >= 51 && two <= 55) return mastercard;
    }
    if (digits.length >= 4) {
      final four = int.tryParse(digits.substring(0, 4)) ?? 0;
      if (four >= 2221 && four <= 2720) return mastercard;
    }
    return other;
  }
}

/// A saved payment card. Only what is needed to recognise it: the full
/// number and the security code are never kept.
class PaymentCard extends Equatable {
  const PaymentCard({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiry,
    this.nickname = '',
  });

  final String id;
  final String last4;
  final CardBrand brand;

  /// `MM/YY`
  final String expiry;
  final String nickname;

  PaymentCard copyWith({String? nickname}) => PaymentCard(
    id: id,
    last4: last4,
    brand: brand,
    expiry: expiry,
    nickname: nickname ?? this.nickname,
  );

  @override
  List<Object?> get props => [id, last4, brand, expiry, nickname];
}

/// What the customer typed to add a card.
class NewCard extends Equatable {
  const NewCard({
    required this.number,
    required this.expiry,
    required this.cvv,
  });

  /// Digits only.
  final String number;

  /// `MM/YY`
  final String expiry;
  final String cvv;

  @override
  List<Object?> get props => [number, expiry, cvv];
}
