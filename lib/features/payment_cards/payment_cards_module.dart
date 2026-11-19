import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../profile/presentation/cubit/edit_text_cubit.dart';
import 'data/datasources/payment_cards_local_data_source.dart';
import 'data/repositories/payment_cards_repository_impl.dart';
import 'domain/entities/payment_card.dart';
import 'domain/repositories/payment_cards_repository.dart';
import 'domain/usecases/payment_cards_use_cases.dart';
import 'domain/validators/card_validators.dart';
import 'presentation/cubit/add_card_cubit.dart';
import 'presentation/cubit/payment_cards_cubit.dart';
import 'presentation/pages/add_payment_card_page.dart';
import 'presentation/pages/card_nickname_page.dart';
import 'presentation/pages/payment_cards_page.dart';

/// The payment cards feature: the list, adding a card (then naming it) and
/// editing or deleting one.
class PaymentCardsModule {
  PaymentCardsModule(
    LocalStorage storage, {
    DateTime Function() now = DateTime.now,
    String Function()? newId,
  }) : _repository = PaymentCardsRepositoryImpl(
         StoragePaymentCardsLocalDataSource(storage),
         newId: newId,
       ),
       _now = now;

  final PaymentCardsRepository _repository;
  final DateTime Function() _now;

  /// The saved cards (checkout lists them as payment methods).
  GetPaymentCards get getCards => GetPaymentCards(_repository);

  /// Removes a saved card.
  DeletePaymentCard get deleteCard => DeletePaymentCard(_repository);

  /// Opens the add-card form; completes with the saved card, or null when the
  /// customer left without adding one.
  Future<PaymentCard?> addCard(BuildContext context) =>
      Navigator.of(context).push<PaymentCard>(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => AddCardCubit(
              addCard: AddPaymentCard(_repository),
              expiryValidator: CardExpiryValidator(now: _now),
            ),
            child: const AddPaymentCardPage(),
          ),
        ),
      );

  /// Opens the cards list over the current page.
  Future<void> open(BuildContext context) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => PaymentCardsCubit(GetPaymentCards(_repository))..load(),
        child: Builder(
          builder: (pageContext) => PaymentCardsPage(
            onAdd: () => _add(pageContext),
            onEdit: (card) => _edit(pageContext, card),
          ),
        ),
      ),
    ),
  );

  Future<void> _add(BuildContext context) async {
    final navigator = Navigator.of(context);
    final card = await addCard(context);
    // A new card is named right away (the name is optional).
    if (card != null) await _nickname(navigator, card, editing: false);
  }

  Future<void> _edit(BuildContext context, PaymentCard card) =>
      _nickname(Navigator.of(context), card, editing: true);

  Future<void> _nickname(
    NavigatorState navigator,
    PaymentCard card, {
    required bool editing,
  }) => navigator.push<void>(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => EditTextCubit<PaymentCard>(
          initial: card.nickname,
          validator: const CardNicknameValidator(),
          normalize: (raw) => raw.trim(),
          save: (value) => SetCardNickname(_repository)(card.id, value),
        ),
        child: Builder(
          builder: (pageContext) => CardNicknamePage(
            card: card,
            onDelete: editing ? () => _confirmDelete(pageContext, card) : null,
          ),
        ),
      ),
    ),
  );

  Future<bool> _confirmDelete(BuildContext context, PaymentCard card) async {
    String t(String key) => 'cards.$key'.tr(context: context);
    final confirmed = await showConfirmDialog(
      context,
      title: t('delete_title'),
      message: t('delete_message'),
      confirmLabel: t('delete_confirm'),
      cancelLabel: t('cancel'),
    );
    if (!confirmed) return false;
    return (await DeletePaymentCard(_repository)(
      card.id,
    )).when(success: (_) => true, failure: (_) => false);
  }
}
