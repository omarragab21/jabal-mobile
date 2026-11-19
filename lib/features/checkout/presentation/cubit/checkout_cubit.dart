import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../address/domain/entities/delivery_location.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/domain/usecases/cart_use_cases.dart';
import '../../../payment_cards/domain/entities/payment_card.dart';
import '../../../payment_cards/domain/usecases/payment_cards_use_cases.dart';
import '../../domain/entities/checkout_entities.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/services/pricing_calculator.dart';
import '../../domain/usecases/checkout_use_cases.dart';

enum CheckoutStatus { loading, ready, failed }

/// The state of the discount code field.
enum PromoStatus { idle, applying, applied, invalid }

/// Where placing the order is.
enum OrderPhase {
  idle,
  submitting,

  /// Accepted; the payment continues in the gateway page.
  awaitingGateway,
  placed,
  failed,
}

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.loading,
    this.cart = const Cart.empty(),
    this.options,
    this.cards = const [],
    this.method = const CashPayment(),
    this.useWallet = false,
    this.address,
    this.promoText = '',
    this.promoStatus = PromoStatus.idle,
    this.promo,
    this.phase = OrderPhase.idle,
    this.placedOrder,
  });

  final CheckoutStatus status;
  final Cart cart;
  final CheckoutOptions? options;
  final List<PaymentCard> cards;
  final PaymentMethod method;
  final bool useWallet;

  /// Where the order goes; null until the customer chooses.
  final DeliveryLocation? address;
  final String promoText;
  final PromoStatus promoStatus;
  final PromoDiscount? promo;
  final OrderPhase phase;
  final PlacedOrder? placedOrder;

  CheckoutPricing get pricing => PricingCalculator.calculate(
    cart: cart,
    deliveryFee: options?.deliveryFee ?? 0,
    promo: promo,
    useWallet: useWallet,
    walletBalance: options?.walletBalance ?? 0,
  );

  bool get canApplyPromo =>
      promoText.trim().isNotEmpty &&
      promoStatus != PromoStatus.applying &&
      !(promoStatus == PromoStatus.applied && promo?.code == promoText.trim());

  bool get canConfirm =>
      status == CheckoutStatus.ready &&
      !cart.isEmpty &&
      address != null &&
      phase == OrderPhase.idle;

  CheckoutState copyWith({
    CheckoutStatus? status,
    Cart? cart,
    CheckoutOptions? options,
    List<PaymentCard>? cards,
    PaymentMethod? method,
    bool? useWallet,
    DeliveryLocation? Function()? address,
    String? promoText,
    PromoStatus? promoStatus,
    PromoDiscount? Function()? promo,
    OrderPhase? phase,
    PlacedOrder? placedOrder,
  }) => CheckoutState(
    status: status ?? this.status,
    cart: cart ?? this.cart,
    options: options ?? this.options,
    cards: cards ?? this.cards,
    method: method ?? this.method,
    useWallet: useWallet ?? this.useWallet,
    address: address != null ? address() : this.address,
    promoText: promoText ?? this.promoText,
    promoStatus: promoStatus ?? this.promoStatus,
    promo: promo != null ? promo() : this.promo,
    phase: phase ?? this.phase,
    placedOrder: placedOrder ?? this.placedOrder,
  );

  @override
  List<Object?> get props => [
    status,
    cart,
    options,
    cards,
    method,
    useWallet,
    address,
    promoText,
    promoStatus,
    promo,
    phase,
    placedOrder,
  ];
}

/// View model of the checkout page: loads the cart and the payment options,
/// keeps the customer's choices and places the order.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required GetCurrentCart getCurrentCart,
    required GetCheckoutOptions getOptions,
    required ApplyPromoCode applyPromoCode,
    required PlaceOrder placeOrder,
    required GetPaymentCards getCards,
    required ClearCart clearCart,
    DeliveryLocation? address,
  }) : _getCurrentCart = getCurrentCart,
       _getOptions = getOptions,
       _applyPromoCode = applyPromoCode,
       _placeOrder = placeOrder,
       _getCards = getCards,
       _clearCart = clearCart,
       super(CheckoutState(address: address));

  final GetCurrentCart _getCurrentCart;
  final GetCheckoutOptions _getOptions;
  final ApplyPromoCode _applyPromoCode;
  final PlaceOrder _placeOrder;
  final GetPaymentCards _getCards;
  final ClearCart _clearCart;

  Future<void> load(String languageCode) async {
    emit(state.copyWith(status: CheckoutStatus.loading));
    final results = await Future.wait([
      _getCurrentCart(languageCode),
      _getOptions(),
      _getCards(),
    ]);
    if (isClosed) return;
    final cart = results[0].when(
      success: (v) => v as Cart,
      failure: (_) => null,
    );
    final options = results[1].when(
      success: (v) => v as CheckoutOptions,
      failure: (_) => null,
    );
    if (cart == null || options == null) {
      emit(state.copyWith(status: CheckoutStatus.failed));
      return;
    }
    // Saved cards are a convenience: checkout works without them.
    final cards = results[2].when(
      success: (v) => v as List<PaymentCard>,
      failure: (_) => const <PaymentCard>[],
    );
    emit(
      state.copyWith(
        status: CheckoutStatus.ready,
        cart: cart,
        options: options,
        cards: cards,
      ),
    );
  }

  void setAddress(DeliveryLocation? address) {
    if (address != state.address) emit(state.copyWith(address: () => address));
  }

  void selectMethod(PaymentMethod method) {
    if (method != state.method) emit(state.copyWith(method: method));
  }

  void toggleWallet(bool value) => emit(state.copyWith(useWallet: value));

  /// A card was added (and verified): list it and pay with it.
  Future<void> cardAdded(PaymentCard card) async {
    final cards = (await _getCards()).when(
      success: (list) => list,
      failure: (_) => [...state.cards, card],
    );
    if (isClosed) return;
    emit(state.copyWith(cards: cards, method: CardPayment(card)));
  }

  void promoChanged(String text) {
    // Editing an applied code takes its discount off until applied again.
    final changed = text.trim() != state.promo?.code;
    emit(
      state.copyWith(
        promoText: text,
        promoStatus: PromoStatus.idle,
        promo: changed ? () => null : null,
      ),
    );
  }

  Future<void> applyPromo() async {
    if (!state.canApplyPromo) return;
    final code = state.promoText.trim();
    emit(state.copyWith(promoStatus: PromoStatus.applying));
    final result = await _applyPromoCode(code, state.cart.subtotal);
    if (isClosed) return;
    result.when(
      success: (promo) => emit(
        state.copyWith(promoStatus: PromoStatus.applied, promo: () => promo),
      ),
      failure: (_) => emit(
        state.copyWith(promoStatus: PromoStatus.invalid, promo: () => null),
      ),
    );
  }

  String _methodId(PaymentMethod method) => switch (method) {
    CashPayment() => 'cash',
    ApplePayPayment() => 'apple_pay',
    CardPayment(:final card) => 'card:${card.id}',
  };

  Future<void> confirm() async {
    final address = state.address;
    if (!state.canConfirm || address == null) return;
    emit(state.copyWith(phase: OrderPhase.submitting));
    final request = PlaceOrderRequest(
      lines: [
        for (final item in state.cart.items)
          OrderLineRequest(productId: item.product.id, quantity: item.quantity),
      ],
      addressId: address.addressId,
      addressLabel: address.label,
      addressDetails: address.details,
      paymentMethod: _methodId(state.method),
      pricing: state.pricing,
      promoCode: state.promo?.code,
      useWallet: state.useWallet,
    );
    final result = await _placeOrder(request);
    if (isClosed) return;
    await result.when(
      success: (placed) async {
        if (placed.needsGateway) {
          emit(
            state.copyWith(
              phase: OrderPhase.awaitingGateway,
              placedOrder: placed,
            ),
          );
        } else {
          await _finish(placed);
        }
      },
      failure: (_) async => emit(state.copyWith(phase: OrderPhase.failed)),
    );
  }

  /// The gateway page is done: [paid] says whether the payment went through.
  Future<void> completeGateway({required bool paid}) async {
    final placed = state.placedOrder;
    if (placed == null) return;
    if (paid) {
      await _finish(placed);
    } else {
      emit(state.copyWith(phase: OrderPhase.failed));
    }
  }

  Future<void> _finish(PlacedOrder placed) async {
    await _clearCart();
    if (isClosed) return;
    emit(state.copyWith(phase: OrderPhase.placed, placedOrder: placed));
  }

  /// The failure was shown; the customer may try again.
  void acknowledgeFailure() {
    if (state.phase == OrderPhase.failed) {
      emit(state.copyWith(phase: OrderPhase.idle));
    }
  }
}
