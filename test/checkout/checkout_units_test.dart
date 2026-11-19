import 'package:dr_jabel/core/error/failures.dart';
import 'package:dr_jabel/core/utils/result.dart';
import 'package:dr_jabel/features/address/domain/entities/delivery_location.dart';
import 'package:dr_jabel/features/address/domain/entities/geo_point.dart';
import 'package:dr_jabel/features/cart/data/datasources/mock_cart_catalogue.dart';
import 'package:dr_jabel/features/cart/data/repositories/mock_cart_repository.dart';
import 'package:dr_jabel/features/cart/domain/entities/cart.dart';
import 'package:dr_jabel/features/cart/domain/usecases/cart_use_cases.dart';
import 'package:dr_jabel/features/checkout/data/datasources/mock_checkout_remote_data_source.dart';
import 'package:dr_jabel/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:dr_jabel/features/checkout/domain/entities/checkout_entities.dart';
import 'package:dr_jabel/features/checkout/domain/entities/payment_method.dart';
import 'package:dr_jabel/features/checkout/domain/services/pricing_calculator.dart';
import 'package:dr_jabel/features/checkout/domain/usecases/checkout_use_cases.dart';
import 'package:dr_jabel/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:dr_jabel/features/payment_cards/domain/entities/payment_card.dart';
import 'package:dr_jabel/features/payment_cards/domain/repositories/payment_cards_repository.dart';
import 'package:dr_jabel/features/payment_cards/domain/usecases/payment_cards_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

const _vitaminC = 104; // 6.50
const _vitaminD = 105; // 9.75 -> 8.25

const _home = DeliveryLocation(
  point: GeoPoint(31.95, 35.91),
  label: 'البيت',
  details: '32, سهيل بن عمرو',
  addressId: 'a1',
);

const _visa = PaymentCard(
  id: 'c1',
  last4: '8283',
  brand: CardBrand.visa,
  expiry: '04/29',
);

class _FakeCards implements PaymentCardsRepository {
  _FakeCards([List<PaymentCard> cards = const []]) : cards = [...cards];

  final List<PaymentCard> cards;

  @override
  Future<Result<List<PaymentCard>>> getCards() async => Success([...cards]);

  @override
  Future<Result<PaymentCard>> addCard(NewCard card) =>
      throw UnimplementedError();

  @override
  Future<Result<PaymentCard>> setNickname(String id, String nickname) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> deleteCard(String id) => throw UnimplementedError();
}

class _Setup {
  _Setup({
    Map<int, int> cartLines = const {_vitaminC: 2},
    List<PaymentCard> cards = const [],
    DeliveryLocation? address = _home,
  }) : cart = MockCartRepository(initial: cartLines) {
    final repository = _repo();
    cubit = CheckoutCubit(
      getCurrentCart: GetCurrentCart(
        GetCartLines(cart),
        const GetCart(MockCartCatalogue(latency: Duration.zero)),
      ),
      getOptions: GetCheckoutOptions(repository),
      applyPromoCode: ApplyPromoCode(repository),
      placeOrder: PlaceOrder(repository),
      getCards: GetPaymentCards(_FakeCards(cards)),
      clearCart: ClearCart(cart),
      address: address,
    );
  }

  final MockCartRepository cart;
  late final CheckoutCubit cubit;
}

/// The mock backend without its fake network delay.
CheckoutRepositoryImpl _repo() => CheckoutRepositoryImpl(
  MockCheckoutRemoteDataSource(latency: Duration.zero),
);

void main() {
  group('PricingCalculator', () {
    const vitaminC = CartProduct(id: 1, name: 'C', price: 6.5, finalPrice: 6.5);
    const vitaminD = CartProduct(
      id: 2,
      name: 'D',
      price: 9.75,
      finalPrice: 8.25,
    );
    const cart = Cart([
      CartItem(product: vitaminC, quantity: 2),
      CartItem(product: vitaminD, quantity: 1),
    ]); // 13.00 + 8.25 = 21.25, saves 1.50

    test('adds the delivery fee to the subtotal', () {
      final pricing = PricingCalculator.calculate(cart: cart, deliveryFee: 2);
      expect(pricing.subtotal, closeTo(21.25, 1e-9));
      expect(pricing.savings, closeTo(1.5, 1e-9));
      expect(pricing.deliveryFee, 2);
      expect(pricing.total, closeTo(23.25, 1e-9));
      expect(pricing.payable, closeTo(23.25, 1e-9));
    });

    test('a promo takes its amount off the products, not the delivery', () {
      final pricing = PricingCalculator.calculate(
        cart: cart,
        deliveryFee: 2,
        promo: const PromoDiscount(code: 'X', amount: 5),
      );
      expect(pricing.promoDiscount, 5);
      expect(pricing.total, closeTo(18.25, 1e-9));
    });

    test('a promo never takes off more than the products cost', () {
      final pricing = PricingCalculator.calculate(
        cart: cart,
        deliveryFee: 2,
        promo: const PromoDiscount(code: 'X', amount: 500),
      );
      expect(pricing.promoDiscount, closeTo(21.25, 1e-9));
      expect(pricing.total, 2, reason: 'only the delivery is left');
    });

    test('the wallet pays what it holds, never more than is due', () {
      final partly = PricingCalculator.calculate(
        cart: cart,
        deliveryFee: 2,
        useWallet: true,
        walletBalance: 10,
      );
      expect(partly.walletUsed, 10);
      expect(partly.payable, closeTo(13.25, 1e-9));

      final fully = PricingCalculator.calculate(
        cart: cart,
        deliveryFee: 2,
        useWallet: true,
        walletBalance: 100,
      );
      expect(fully.walletUsed, closeTo(23.25, 1e-9));
      expect(fully.payable, closeTo(0, 1e-9));
    });

    test('the wallet is left alone when its switch is off', () {
      final pricing = PricingCalculator.calculate(
        cart: cart,
        deliveryFee: 2,
        walletBalance: 10,
      );
      expect(pricing.walletUsed, 0);
    });

    test('an empty cart costs nothing, not even delivery', () {
      final pricing = PricingCalculator.calculate(
        cart: const Cart.empty(),
        deliveryFee: 2,
      );
      expect(pricing.total, 0);
      expect(pricing.deliveryFee, 0);
    });
  });

  group('CheckoutRepositoryImpl', () {
    final repository = _repo();

    test('the options have a wallet, a fee and Apple Pay', () async {
      final options = (await repository.getOptions()).when(
        success: (o) => o,
        failure: (f) => fail('$f'),
      );
      expect(options.walletBalance, 12.5);
      expect(options.deliveryFee, 2);
      expect(options.applePayAvailable, isTrue);
    });

    test('codes work in any letter case', () async {
      final percent = (await repository.validatePromo(
        'JABAL2026',
        20,
      )).when(success: (p) => p, failure: (f) => fail('$f'));
      expect(percent.amount, closeTo(2, 1e-9));

      final fixed = (await repository.validatePromo(
        'pharmajable',
        20,
      )).when(success: (p) => p, failure: (f) => fail('$f'));
      expect(fixed.amount, 5);
    });

    test('a fixed code never exceeds the subtotal', () async {
      final promo = (await repository.validatePromo(
        'PharmaJable',
        3,
      )).when(success: (p) => p, failure: (f) => fail('$f'));
      expect(promo.amount, 3);
    });

    test('an unknown code is an InvalidPromoCodeFailure', () async {
      (await repository.validatePromo('nope', 20)).when(
        success: (_) => fail('should be rejected'),
        failure: (f) => expect(f, isA<InvalidPromoCodeFailure>()),
      );
    });
  });

  group('CheckoutCubit', () {
    test('loads the cart, the options and the saved cards', () async {
      final s = _Setup(cards: const [_visa]);
      await s.cubit.load('ar');
      final state = s.cubit.state;
      expect(state.status, CheckoutStatus.ready);
      expect(state.cart.itemsCount, 2);
      expect(state.options?.walletBalance, 12.5);
      expect(state.cards, const [_visa]);
      expect(state.method, const CashPayment());
      expect(state.pricing.total, closeTo(15, 1e-9)); // 13.00 + 2.00
      await s.cubit.close();
    });

    test('the promo field: apply, edit, reject', () async {
      final s = _Setup();
      await s.cubit.load('ar');

      s.cubit.promoChanged('Jabal2026');
      expect(s.cubit.state.canApplyPromo, isTrue);
      await s.cubit.applyPromo();
      expect(s.cubit.state.promoStatus, PromoStatus.applied);
      expect(s.cubit.state.promo?.amount, closeTo(1.3, 1e-9));
      expect(s.cubit.state.pricing.total, closeTo(13.7, 1e-9));
      expect(s.cubit.state.canApplyPromo, isFalse, reason: 'already applied');

      // Editing the applied code takes its discount off until applied again.
      s.cubit.promoChanged('Jabal20');
      expect(s.cubit.state.promo, isNull);
      expect(s.cubit.state.pricing.total, closeTo(15, 1e-9));

      await s.cubit.applyPromo();
      expect(s.cubit.state.promoStatus, PromoStatus.invalid);
      expect(s.cubit.state.promo, isNull);
      await s.cubit.close();
    });

    test('an empty field cannot be applied', () async {
      final s = _Setup();
      await s.cubit.load('ar');
      s.cubit.promoChanged('   ');
      expect(s.cubit.state.canApplyPromo, isFalse);
      await s.cubit.close();
    });

    test('the wallet lowers what is payable', () async {
      final s = _Setup();
      await s.cubit.load('ar');
      s.cubit.toggleWallet(true);
      expect(s.cubit.state.pricing.walletUsed, 12.5);
      expect(s.cubit.state.pricing.payable, closeTo(2.5, 1e-9));
      await s.cubit.close();
    });

    test('nothing can be confirmed without an address', () async {
      final s = _Setup(address: null);
      await s.cubit.load('ar');
      expect(s.cubit.state.canConfirm, isFalse);
      await s.cubit.confirm();
      expect(s.cubit.state.phase, OrderPhase.idle);

      s.cubit.setAddress(_home);
      expect(s.cubit.state.canConfirm, isTrue);
      await s.cubit.close();
    });

    test('cash: the order is placed at once and the cart is emptied', () async {
      final s = _Setup();
      await s.cubit.load('ar');
      await s.cubit.confirm();

      expect(s.cubit.state.phase, OrderPhase.placed);
      expect(s.cubit.state.placedOrder?.number, startsWith('ORD-2026-'));
      expect(s.cubit.state.placedOrder?.needsGateway, isFalse);
      expect(await s.cart.watchItemCount().first, 0);
      await s.cubit.close();
    });

    test('a card goes through the gateway before the order counts', () async {
      final s = _Setup(cards: const [_visa]);
      await s.cubit.load('ar');
      s.cubit.selectMethod(const CardPayment(_visa));
      await s.cubit.confirm();

      expect(s.cubit.state.phase, OrderPhase.awaitingGateway);
      expect(s.cubit.state.placedOrder?.needsGateway, isTrue);
      expect(await s.cart.watchItemCount().first, 2, reason: 'not paid yet');

      await s.cubit.completeGateway(paid: true);
      expect(s.cubit.state.phase, OrderPhase.placed);
      expect(await s.cart.watchItemCount().first, 0);
      await s.cubit.close();
    });

    test('a payment that did not go through keeps the cart', () async {
      final s = _Setup();
      await s.cubit.load('ar');
      s.cubit.selectMethod(const ApplePayPayment());
      await s.cubit.confirm();
      await s.cubit.completeGateway(paid: false);

      expect(s.cubit.state.phase, OrderPhase.failed);
      expect(await s.cart.watchItemCount().first, 2);

      s.cubit.acknowledgeFailure();
      expect(s.cubit.state.phase, OrderPhase.idle);
      expect(s.cubit.state.canConfirm, isTrue, reason: 'may try again');
      await s.cubit.close();
    });

    test('a wallet that covers everything needs no gateway', () async {
      final s = _Setup(cartLines: const {_vitaminD: 1}); // 8.25 + 2.00
      await s.cubit.load('ar');
      s.cubit.selectMethod(const ApplePayPayment());
      s.cubit.toggleWallet(true); // 12.50 covers 10.25
      expect(s.cubit.state.pricing.payable, closeTo(0, 1e-9));

      await s.cubit.confirm();
      expect(s.cubit.state.phase, OrderPhase.placed);
      await s.cubit.close();
    });

    test('a card added at checkout is listed and selected', () async {
      final repository = _FakeCards();
      final s = _Setup();
      await s.cubit.load('ar');
      expect(s.cubit.state.cards, isEmpty);

      repository.cards.add(_visa);
      // The cubit re-reads the cards: use a fresh cubit over the same list.
      final cubit = CheckoutCubit(
        getCurrentCart: GetCurrentCart(
          GetCartLines(s.cart),
          const GetCart(MockCartCatalogue(latency: Duration.zero)),
        ),
        getOptions: GetCheckoutOptions(_repo()),
        applyPromoCode: ApplyPromoCode(_repo()),
        placeOrder: PlaceOrder(_repo()),
        getCards: GetPaymentCards(repository),
        clearCart: ClearCart(s.cart),
        address: _home,
      );
      await cubit.load('ar');
      await cubit.cardAdded(_visa);
      expect(cubit.state.method, const CardPayment(_visa));
      expect(cubit.state.cards, const [_visa]);
      await cubit.close();
      await s.cubit.close();
    });
  });
}
