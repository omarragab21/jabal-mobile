import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/payment_card.dart';
import '../../domain/repositories/payment_cards_repository.dart';
import '../datasources/payment_cards_local_data_source.dart';

/// Saves cards on the device, as their last four digits only. A real payment
/// provider replaces this class: it would tokenize the card and keep the
/// token.
class PaymentCardsRepositoryImpl implements PaymentCardsRepository {
  PaymentCardsRepositoryImpl(this._local, {String Function()? newId})
    : _newId = newId ?? _timestampId;

  final PaymentCardsLocalDataSource _local;
  final String Function() _newId;

  static String _timestampId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  @override
  Future<Result<List<PaymentCard>>> getCards() =>
      guard(() async => _local.read());

  @override
  Future<Result<PaymentCard>> addCard(NewCard card) => guard(() async {
    final saved = PaymentCard(
      id: _newId(),
      last4: card.number.substring(card.number.length - 4),
      brand: CardBrand.of(card.number),
      expiry: card.expiry,
    );
    await _local.write([..._local.read(), saved]);
    return saved;
  });

  @override
  Future<Result<PaymentCard>> setNickname(String id, String nickname) =>
      guard(() async {
        final cards = _local.read();
        final index = cards.indexWhere((c) => c.id == id);
        if (index < 0) throw const NotFoundException();
        final updated = cards[index].copyWith(nickname: nickname.trim());
        cards[index] = updated;
        await _local.write(cards);
        return updated;
      });

  @override
  Future<Result<void>> deleteCard(String id) => guard(() async {
    await _local.write([
      for (final c in _local.read())
        if (c.id != id) c,
    ]);
  });
}
