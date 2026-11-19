import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/payment_card.dart';

abstract interface class PaymentCardsLocalDataSource {
  List<PaymentCard> read();
  Future<void> write(List<PaymentCard> cards);
}

/// Keeps the saved cards as JSON in [LocalStorage]. Unreadable data counts
/// as no cards.
class StoragePaymentCardsLocalDataSource
    implements PaymentCardsLocalDataSource {
  const StoragePaymentCardsLocalDataSource(this._storage);

  final LocalStorage _storage;

  @override
  List<PaymentCard> read() {
    final raw = _storage.getString(StorageKeys.paymentCards);
    if (raw == null) return const [];
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const [];
    }
    return [for (final item in JsonReader.mapList(decoded)) ?_fromJson(item)];
  }

  static PaymentCard? _fromJson(Map<String, dynamic> json) {
    final id = JsonReader.stringOrNull(json['id']);
    final last4 = JsonReader.string(json['last4']);
    final expiry = JsonReader.string(json['expiry']);
    if (id == null || !RegExp(r'^\d{4}$').hasMatch(last4)) return null;
    final brand = CardBrand.values.firstWhere(
      (b) => b.name == json['brand'],
      orElse: () => CardBrand.other,
    );
    return PaymentCard(
      id: id,
      last4: last4,
      brand: brand,
      expiry: expiry,
      nickname: JsonReader.string(json['nickname']),
    );
  }

  @override
  Future<void> write(List<PaymentCard> cards) => _storage.setString(
    StorageKeys.paymentCards,
    jsonEncode([
      for (final card in cards)
        {
          'id': card.id,
          'last4': card.last4,
          'brand': card.brand.name,
          'expiry': card.expiry,
          'nickname': card.nickname,
        },
    ]),
  );
}
