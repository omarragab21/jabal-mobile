import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../address/address_module.dart';
import '../address/presentation/cubit/delivery_location_cubit.dart';
import '../cart/cart_module.dart';
import '../legal/legal_module.dart';
import '../payment_cards/domain/entities/payment_card.dart';
import '../payment_cards/payment_cards_module.dart';
import 'data/datasources/checkout_remote_data_source.dart';
import 'data/datasources/mock_checkout_remote_data_source.dart';
import 'data/repositories/checkout_repository_impl.dart';
import 'domain/repositories/checkout_repository.dart';
import 'domain/usecases/checkout_use_cases.dart';
import 'presentation/cubit/checkout_cubit.dart';
import 'presentation/pages/checkout_page.dart';
import 'presentation/pages/payment_gateway_page.dart';

/// Checkout: from "continue to checkout" in the cart to the order placed. It
/// reads the cart, the delivery address and the saved cards from their own
/// modules and runs on mock data until a real [CheckoutRemoteDataSource] is
/// passed as [remote].
class CheckoutModule {
  CheckoutModule({
    required CartModule cart,
    required AddressModule address,
    required PaymentCardsModule paymentCards,
    required LegalModule legal,
    CheckoutRemoteDataSource? remote,
    Duration latency = const Duration(milliseconds: 400),
  }) : _cart = cart,
       _address = address,
       _paymentCards = paymentCards,
       _legal = legal,
       _repository = CheckoutRepositoryImpl(
         remote ?? MockCheckoutRemoteDataSource(latency: latency),
       );

  final CartModule _cart;
  final AddressModule _address;
  final PaymentCardsModule _paymentCards;
  final LegalModule _legal;
  final CheckoutRepository _repository;

  /// Opens checkout over the cart. [onBackHome] runs when the customer leaves
  /// the order confirmation.
  Future<void> open(
    BuildContext context, {
    required void Function(BuildContext context) onBackHome,
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<DeliveryLocationCubit>.value(
            value: _address.deliveryLocation,
          ),
          BlocProvider(
            create: (_) => CheckoutCubit(
              getCurrentCart: GetCurrentCart(_cart.getCartLines, _cart.getCart),
              getOptions: GetCheckoutOptions(_repository),
              applyPromoCode: ApplyPromoCode(_repository),
              placeOrder: PlaceOrder(_repository),
              getCards: _paymentCards.getCards,
              clearCart: _cart.clearCart,
              address: _address.deliveryLocation.state.selection,
            ),
          ),
        ],
        child: CheckoutPage(
          onChangeAddress: _address.openDeliverySheet,
          onAddCard: _addVerifiedCard,
          onOpenTerms: (ctx) => _legal.openTerms(ctx),
          onOpenPrivacy: (ctx) => _legal.openPrivacy(ctx),
          onBackHome: onBackHome,
        ),
      ),
    ),
  );

  /// The add-card form, then the gateway's verification. A card that is not
  /// verified is removed again, so none is kept half-added.
  Future<PaymentCard?> _addVerifiedCard(BuildContext context) async {
    final navigator = Navigator.of(context);
    final card = await _paymentCards.addCard(context);
    if (card == null) return null;
    final verified = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => const PaymentGatewayPage()),
    );
    if (verified == true) return card;
    await _paymentCards.deleteCard(card.id);
    return null;
  }
}
