import '../../../../core/utils/result.dart';
import '../entities/payment_card.dart';

abstract interface class PaymentCardsRepository {
  Future<Result<List<PaymentCard>>> getCards();

  /// Saves the card (without its number and code) and returns it.
  Future<Result<PaymentCard>> addCard(NewCard card);

  Future<Result<PaymentCard>> setNickname(String id, String nickname);

  Future<Result<void>> deleteCard(String id);
}
