import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment_card.dart';
import '../../domain/usecases/payment_cards_use_cases.dart';

enum PaymentCardsStatus { loading, ready, failed }

class PaymentCardsState extends Equatable {
  const PaymentCardsState({
    this.status = PaymentCardsStatus.loading,
    this.cards = const [],
  });

  final PaymentCardsStatus status;
  final List<PaymentCard> cards;

  @override
  List<Object?> get props => [status, cards];
}

class PaymentCardsCubit extends Cubit<PaymentCardsState> {
  PaymentCardsCubit(this._getCards) : super(const PaymentCardsState());

  final GetPaymentCards _getCards;

  Future<void> load() async {
    final result = await _getCards();
    if (isClosed) return;
    result.when(
      success: (cards) => emit(
        PaymentCardsState(status: PaymentCardsStatus.ready, cards: cards),
      ),
      failure: (_) => emit(
        PaymentCardsState(
          status: PaymentCardsStatus.failed,
          cards: state.cards,
        ),
      ),
    );
  }
}
