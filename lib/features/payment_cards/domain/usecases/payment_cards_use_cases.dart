import '../../../../core/utils/result.dart';
import '../entities/payment_card.dart';
import '../repositories/payment_cards_repository.dart';

class GetPaymentCards {
  const GetPaymentCards(this._repository);
  final PaymentCardsRepository _repository;

  Future<Result<List<PaymentCard>>> call() => _repository.getCards();
}

class AddPaymentCard {
  const AddPaymentCard(this._repository);
  final PaymentCardsRepository _repository;

  Future<Result<PaymentCard>> call(NewCard card) => _repository.addCard(card);
}

class SetCardNickname {
  const SetCardNickname(this._repository);
  final PaymentCardsRepository _repository;

  Future<Result<PaymentCard>> call(String id, String nickname) =>
      _repository.setNickname(id, nickname);
}

class DeletePaymentCard {
  const DeletePaymentCard(this._repository);
  final PaymentCardsRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteCard(id);
}
