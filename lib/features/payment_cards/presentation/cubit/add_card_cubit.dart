import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/validation/validation_error.dart';
import '../../domain/entities/payment_card.dart';
import '../../domain/usecases/payment_cards_use_cases.dart';
import '../../domain/validators/card_validators.dart';

class AddCardState extends Equatable {
  const AddCardState({
    this.brand = CardBrand.other,
    this.numberError,
    this.expiryError,
    this.cvvError,
    this.saving = false,
    this.saved,
    this.failure,
  });

  /// The brand the typed number belongs to.
  final CardBrand brand;
  final ValidationError? numberError;
  final ValidationError? expiryError;
  final ValidationError? cvvError;
  final bool saving;

  /// Set once the card is saved.
  final PaymentCard? saved;
  final Failure? failure;

  AddCardState copyWith({
    CardBrand? brand,
    ValidationError? Function()? numberError,
    ValidationError? Function()? expiryError,
    ValidationError? Function()? cvvError,
    bool? saving,
    PaymentCard? saved,
    Failure? Function()? failure,
  }) => AddCardState(
    brand: brand ?? this.brand,
    numberError: numberError != null ? numberError() : this.numberError,
    expiryError: expiryError != null ? expiryError() : this.expiryError,
    cvvError: cvvError != null ? cvvError() : this.cvvError,
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    brand,
    numberError,
    expiryError,
    cvvError,
    saving,
    saved,
    failure,
  ];
}

/// Adding a card: validates each field (after the first attempt, live) and
/// saves it.
class AddCardCubit extends Cubit<AddCardState> {
  AddCardCubit({
    required AddPaymentCard addCard,
    CardNumberValidator numberValidator = const CardNumberValidator(),
    CardExpiryValidator expiryValidator = const CardExpiryValidator(),
    CvvValidator cvvValidator = const CvvValidator(),
  }) : _addCard = addCard,
       _number = numberValidator,
       _expiry = expiryValidator,
       _cvv = cvvValidator,
       super(const AddCardState());

  final AddPaymentCard _addCard;
  final CardNumberValidator _number;
  final CardExpiryValidator _expiry;
  final CvvValidator _cvv;

  String _numberText = '';
  String _expiryText = '';
  String _cvvText = '';
  bool _submitted = false;

  void numberChanged(String text) {
    _numberText = text;
    emit(
      state.copyWith(
        brand: CardBrand.of(CardNumberValidator.digitsOf(text)),
        numberError: _submitted ? () => _number.validate(text) : () => null,
        failure: () => null,
      ),
    );
  }

  void expiryChanged(String text) {
    _expiryText = text;
    emit(
      state.copyWith(
        expiryError: _submitted ? () => _expiry.validate(text) : () => null,
        failure: () => null,
      ),
    );
  }

  void cvvChanged(String text) {
    _cvvText = text;
    emit(
      state.copyWith(
        cvvError: _submitted ? () => _cvv.validate(text) : () => null,
        failure: () => null,
      ),
    );
  }

  Future<void> submit() async {
    if (state.saving) return;
    _submitted = true;
    final numberError = _number.validate(_numberText);
    final expiryError = _expiry.validate(_expiryText);
    final cvvError = _cvv.validate(_cvvText);
    if (numberError != null || expiryError != null || cvvError != null) {
      emit(
        state.copyWith(
          numberError: () => numberError,
          expiryError: () => expiryError,
          cvvError: () => cvvError,
        ),
      );
      return;
    }
    emit(state.copyWith(saving: true, failure: () => null));
    final result = await _addCard(
      NewCard(
        number: CardNumberValidator.digitsOf(_numberText),
        expiry: _expiryText.trim(),
        cvv: _cvvText.trim(),
      ),
    );
    if (isClosed) return;
    result.when(
      success: (card) => emit(state.copyWith(saving: false, saved: card)),
      failure: (f) => emit(state.copyWith(saving: false, failure: () => f)),
    );
  }
}
