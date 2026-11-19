import 'package:dr_jabel/core/error/failures.dart';
import 'package:dr_jabel/core/utils/result.dart';
import 'package:dr_jabel/features/cart/data/datasources/mock_cart_catalogue.dart';
import 'package:dr_jabel/features/cart/data/repositories/mock_cart_repository.dart';
import 'package:dr_jabel/features/cart/domain/entities/cart.dart';
import 'package:dr_jabel/features/cart/domain/entities/cart_line.dart';
import 'package:dr_jabel/features/cart/domain/usecases/cart_use_cases.dart';
import 'package:dr_jabel/features/cart/domain/usecases/update_cart_item.dart';
import 'package:dr_jabel/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _vitaminC = 104; // 6.50
const _vitaminD = 105; // 9.75 -> 8.25
const _omega = 106; // 14.00 -> 11.25

CartCubit _cubit(MockCartRepository repository) => CartCubit(
  watchLines: WatchCartLines(repository),
  getCart: const GetCart(MockCartCatalogue(latency: Duration.zero)),
  updateItem: UpdateCartItem(repository),
  removeItem: RemoveFromCart(repository),
);

Cart _cartOf(Result<Cart> result) =>
    result.when(success: (c) => c, failure: (f) => fail('$f'));

void main() {
  group('Cart totals', () {
    const vitaminC = CartProduct(id: 1, name: 'C', price: 6.5, finalPrice: 6.5);
    const vitaminD = CartProduct(
      id: 2,
      name: 'D',
      price: 9.75,
      finalPrice: 8.25,
    );

    test('count pieces, subtotal and savings', () {
      const cart = Cart([
        CartItem(product: vitaminC, quantity: 2),
        CartItem(product: vitaminD, quantity: 3),
      ]);
      expect(cart.itemsCount, 5);
      expect(cart.subtotal, closeTo(13 + 24.75, 1e-9));
      expect(cart.savings, closeTo(1.5 * 3, 1e-9));
      expect(cart.isEmpty, isFalse);
    });

    test('an empty cart is all zero', () {
      const cart = Cart.empty();
      expect(cart.isEmpty, isTrue);
      expect(cart.itemsCount, 0);
      expect(cart.subtotal, 0);
    });
  });

  group('MockCartRepository', () {
    test('keeps rows in the order they were added', () async {
      final repository = MockCartRepository();
      await repository.addItem(_vitaminD);
      await repository.addItem(_vitaminC, quantity: 2);
      await repository.addItem(_vitaminD);

      final lines = await repository.watchLines().first;
      expect(lines, const [
        CartLine(productId: _vitaminD, quantity: 2),
        CartLine(productId: _vitaminC, quantity: 2),
      ]);
      expect(await repository.watchItemCount().first, 4);
    });

    test('sets, removes and clears', () async {
      final repository = MockCartRepository(initial: {_vitaminC: 1});
      await repository.setItemQuantity(_vitaminC, 5);
      expect(await repository.watchItemCount().first, 5);

      await repository.removeItem(_vitaminC);
      expect(await repository.watchLines().first, isEmpty);

      await repository.addItem(_vitaminD);
      await repository.clear();
      expect(await repository.watchItemCount().first, 0);
    });

    test('a listener hears every change after the first value', () async {
      final repository = MockCartRepository();
      final counts = <int>[];
      final sub = repository.watchItemCount().listen(counts.add);
      await pumpEventQueue();
      await repository.addItem(_vitaminC);
      await repository.addItem(_vitaminC);
      await repository.removeItem(_vitaminC);
      await pumpEventQueue();
      expect(counts, [0, 1, 2, 0]);
      await sub.cancel();
    });
  });

  group('GetCart', () {
    const getCart = GetCart(MockCartCatalogue(latency: Duration.zero));

    test('joins the rows with their products', () async {
      final cart = _cartOf(
        await getCart(const [
          CartLine(productId: _vitaminD, quantity: 2),
          CartLine(productId: _omega, quantity: 1),
        ], 'ar'),
      );
      expect(cart.items.map((i) => i.product.id), [_vitaminD, _omega]);
      expect(cart.items.first.product.name, 'فيتامين د3 5000 وحدة');
      expect(cart.items.first.product.finalPrice, 8.25);
      expect(cart.items.first.product.sizeLabel, '60 كبسولة');
      expect(cart.subtotal, closeTo(8.25 * 2 + 11.25, 1e-9));
    });

    test('a product that no longer exists is left out', () async {
      final cart = _cartOf(
        await getCart(const [
          CartLine(productId: 999999, quantity: 1),
          CartLine(productId: _vitaminC, quantity: 1),
        ], 'ar'),
      );
      expect(cart.items.map((i) => i.product.id), [_vitaminC]);
    });

    test('no rows is an empty cart without asking the catalogue', () async {
      expect(_cartOf(await getCart(const [], 'ar')).isEmpty, isTrue);
    });

    test('the language picks the product texts', () async {
      final cart = _cartOf(
        await getCart(const [
          CartLine(productId: _vitaminD, quantity: 1),
        ], 'en'),
      );
      expect(cart.items.single.product.name, 'Vitamin D3 5000 IU');
    });
  });

  group('CartCubit', () {
    test('follows the repository', () async {
      final repository = MockCartRepository();
      final cubit = _cubit(repository)..start('ar');
      await pumpEventQueue();
      expect(cubit.state.status, CartStatus.ready);
      expect(cubit.state.cart.isEmpty, isTrue);

      await repository.addItem(_vitaminC, quantity: 2);
      await pumpEventQueue();
      expect(cubit.state.cart.itemsCount, 2);
      expect(cubit.state.cart.subtotal, closeTo(13, 1e-9));
      await cubit.close();
    });

    test('increment is capped by the stock', () async {
      final repository = MockCartRepository(initial: {_vitaminC: 99});
      final cubit = _cubit(repository)..start('ar');
      await pumpEventQueue();

      await cubit.increment(cubit.state.cart.items.single);
      await pumpEventQueue();
      expect(cubit.state.cart.itemsCount, 100);

      await cubit.increment(cubit.state.cart.items.single);
      await pumpEventQueue();
      expect(cubit.state.cart.itemsCount, 100, reason: 'stock is 100');
      await cubit.close();
    });

    test('decrement removes the row at one', () async {
      final repository = MockCartRepository(initial: {_vitaminC: 2});
      final cubit = _cubit(repository)..start('ar');
      await pumpEventQueue();

      await cubit.decrement(cubit.state.cart.items.single);
      await pumpEventQueue();
      expect(cubit.state.cart.itemsCount, 1);

      await cubit.decrement(cubit.state.cart.items.single);
      await pumpEventQueue();
      expect(cubit.state.cart.isEmpty, isTrue);
      await cubit.close();
    });

    test('a failing catalogue is a failed state that retry can fix', () async {
      final repository = MockCartRepository(initial: {_vitaminC: 1});
      var healthy = false;
      final cubit = CartCubit(
        watchLines: WatchCartLines(repository),
        getCart: GetCart(_FlakyCatalogue(() => healthy)),
        updateItem: UpdateCartItem(repository),
        removeItem: RemoveFromCart(repository),
      )..start('ar');
      await pumpEventQueue();
      expect(cubit.state.status, CartStatus.failed);

      healthy = true;
      await cubit.retry();
      expect(cubit.state.status, CartStatus.ready);
      expect(cubit.state.cart.itemsCount, 1);
      await cubit.close();
    });
  });
}

class _FlakyCatalogue extends MockCartCatalogue {
  const _FlakyCatalogue(this._healthy) : super(latency: Duration.zero);

  final bool Function() _healthy;

  @override
  Future<Result<List<CartProduct>>> productsByIds(
    List<int> ids,
    String languageCode,
  ) => _healthy()
      ? super.productsByIds(ids, languageCode)
      : Future.value(const Err(NetworkFailure()));
}
