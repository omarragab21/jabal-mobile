import 'package:dr_jabel/core/error/exceptions.dart';
import 'package:dr_jabel/core/error/failures.dart';
import 'package:dr_jabel/core/platform/clipboard_writer.dart';
import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/widgets/count_badge.dart';
import 'package:dr_jabel/features/cart/data/repositories/mock_cart_repository.dart';
import 'package:dr_jabel/features/cart/domain/usecases/add_to_cart.dart';
import 'package:dr_jabel/features/cart/domain/usecases/update_cart_item.dart';
import 'package:dr_jabel/features/cart/domain/usecases/watch_cart_count.dart';
import 'package:dr_jabel/features/product_details/data/datasources/mock_product_details_remote_data_source.dart';
import 'package:dr_jabel/features/product_details/data/repositories/product_details_repository_impl.dart';
import 'package:dr_jabel/core/sharing/share_link.dart';
import 'package:dr_jabel/core/sharing/share_target.dart';
import 'package:dr_jabel/features/product_details/domain/usecases/get_product_details.dart';
import 'package:dr_jabel/features/product_details/presentation/cubit/product_details_cubit.dart';
import 'package:dr_jabel/features/product_details/presentation/pages/product_details_page.dart';
import 'package:dr_jabel/features/product_details/presentation/product_details_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _session = {
  StorageKeys.onboardingSeen: true,
  StorageKeys.authToken: 'mock-token-1',
  StorageKeys.authUser:
      '{"id":"1","name":"Ahmad Ali","phone":"+962791234567","email":null}',
};

class _FakeClipboard implements ClipboardWriter {
  final List<String> copied = [];

  @override
  Future<void> copy(String text) async => copied.add(text);
}

const _vitaminC = 104; // 6.50, no discount, 100 in stock
const _vitaminD = 105; // 9.75, now 8.25

ProductDetailsCubit _cubit(
  MockCartRepository cart,
  ProductDetailsArgs args, {
  RecordingLinkOpener? opener,
  _FakeClipboard? clipboard,
}) => ProductDetailsCubit(
  args: args,
  getProductDetails: GetProductDetails(
    const ProductDetailsRepositoryImpl(
      MockProductDetailsRemoteDataSource(latency: Duration.zero),
    ),
  ),
  addToCart: AddToCart(cart),
  updateCartItem: UpdateCartItem(cart),
  watchCartCount: WatchCartCount(cart),
  shareLink: ShareLink(
    opener ?? RecordingLinkOpener(),
    clipboard ?? _FakeClipboard(),
  ),
);

void main() {
  group('data', () {
    const repository = ProductDetailsRepositoryImpl(
      MockProductDetailsRemoteDataSource(latency: Duration.zero),
    );

    test(
      'a catalogue product opens with its price, pictures and text',
      () async {
        final result = await repository.getProductDetails(_vitaminD, 'ar');
        final product = result.when(
          success: (p) => p,
          failure: (f) => fail('$f'),
        );
        expect(product.name, 'فيتامين د3 5000 وحدة');
        expect(product.price, 9.75);
        expect(product.finalPrice, 8.25);
        expect(product.oldPrice, 9.75);
        expect(product.images, hasLength(3));
        expect(product.images.toSet(), hasLength(3));
        expect(product.description, isNotEmpty);
        expect(product.viewersNow, greaterThan(0));
        expect(product.maxQuantity, 100);
      },
    );

    test('the language picks the texts', () async {
      final en = (await repository.getProductDetails(
        _vitaminD,
        'en',
      )).when(success: (p) => p, failure: (f) => fail('$f'));
      expect(en.name, 'Vitamin D3 5000 IU');
      expect(en.description, contains('Vitamin D3'));
    });

    test('an unknown product is a NotFoundFailure', () async {
      final result = await repository.getProductDetails(999999, 'ar');
      result.when(
        success: (_) => fail('should not be found'),
        failure: (f) => expect(f, isA<NotFoundFailure>()),
      );
    });

    test('the mock source throws NotFoundException for an unknown id', () {
      expect(
        () => const MockProductDetailsRemoteDataSource(
          latency: Duration.zero,
        ).fetchProduct(999999, 'ar'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('ProductDetailsCubit', () {
    test('quantity stays between 1 and the stock', () async {
      final cubit = _cubit(
        MockCartRepository(),
        const ProductDetailsArgs(productId: _vitaminC),
      );
      await cubit.load('ar');
      expect(cubit.state.status, ProductDetailsStatus.ready);
      expect(cubit.state.quantity, 1);

      cubit.decrement();
      expect(cubit.state.quantity, 1, reason: 'never below one');
      cubit
        ..increment()
        ..increment();
      expect(cubit.state.quantity, 3);
      expect(cubit.state.total, closeTo(19.5, 1e-9));

      for (var i = 0; i < 200; i++) {
        cubit.increment();
      }
      expect(cubit.state.quantity, 100, reason: 'capped by the stock');
      expect(cubit.state.canIncrement, isFalse);
      await cubit.close();
    });

    test('adding puts the chosen quantity in the cart', () async {
      final cart = MockCartRepository();
      final cubit = _cubit(
        cart,
        const ProductDetailsArgs(productId: _vitaminC),
      );
      await cubit.load('ar');
      cubit
        ..increment()
        ..increment();

      expect(await cubit.submit(), isTrue);
      await pumpEventQueue();
      expect(cubit.state.cartCount, 3);
      await cubit.close();
    });

    test('opened from a cart line it edits that line instead', () async {
      final cart = MockCartRepository(initial: {_vitaminC: 4});
      final cubit = _cubit(
        cart,
        const ProductDetailsArgs(productId: _vitaminC, cartQuantity: 4),
      );
      await cubit.load('ar');
      expect(cubit.args.isUpdate, isTrue);
      expect(cubit.state.quantity, 4, reason: 'starts at the line quantity');

      cubit.decrement();
      expect(await cubit.submit(), isTrue);
      await pumpEventQueue();
      expect(cubit.state.cartCount, 3, reason: 'replaced, not added to');
      await cubit.close();
    });

    test('an unknown product fails to load', () async {
      final cubit = _cubit(
        MockCartRepository(),
        const ProductDetailsArgs(productId: 999999),
      );
      await cubit.load('ar');
      expect(cubit.state.status, ProductDetailsStatus.failed);
      expect(await cubit.submit(), isFalse);
      await cubit.close();
    });
  });

  group('ShareProduct', () {
    final link = Uri.https('drjabel.app', '/product/104');

    test('each target opens its own address with the link in it', () async {
      final opener = RecordingLinkOpener();
      final share = ShareLink(opener, _FakeClipboard());

      expect(
        await share(ShareTarget.whatsapp, message: 'Look', link: link),
        ShareOutcome.opened,
      );
      await share(ShareTarget.facebook, message: 'Look', link: link);
      await share(ShareTarget.x, message: 'Look', link: link);

      expect(opener.opened[0].host, 'wa.me');
      expect(opener.opened[0].queryParameters['text'], 'Look $link');
      expect(opener.opened[1].host, 'www.facebook.com');
      expect(opener.opened[1].queryParameters['u'], '$link');
      expect(opener.opened[2].queryParameters['url'], '$link');
    });

    test('copy link and Instagram put the link on the clipboard', () async {
      final clipboard = _FakeClipboard();
      final opener = RecordingLinkOpener();
      final share = ShareLink(opener, clipboard);

      expect(
        await share(ShareTarget.copyLink, message: 'x', link: link),
        ShareOutcome.copied,
      );
      expect(opener.opened, isEmpty);

      expect(
        await share(ShareTarget.instagram, message: 'x', link: link),
        ShareOutcome.copied,
      );
      expect(clipboard.copied, ['$link', '$link']);
      expect(opener.opened.single.scheme, 'instagram');
    });

    test('a missing app is a failed outcome', () async {
      final share = ShareLink(
        RecordingLinkOpener(result: false),
        _FakeClipboard(),
      );
      expect(
        await share(ShareTarget.snapchat, message: 'x', link: link),
        ShareOutcome.failed,
      );
    });
  });

  group('page', () {
    Future<void> openProduct(
      WidgetTester tester, {
      RecordingLinkOpener? opener,
    }) async {
      await pumpApp(tester, _session, linkOpener: opener);
      final card = find.byKey(const ValueKey('product-$_vitaminC'));
      await tester.scrollUntilVisible(
        card,
        300,
        scrollable: find
            .descendant(
              of: find.byType(RefreshIndicator),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
    }

    testWidgets('a tapped product opens its page and adds to the cart', (
      tester,
    ) async {
      await openProduct(tester);

      expect(
        find.text('فيتامين سي 1000 مجم أقراص فوارة بنكهة البرتقال'),
        findsOneWidget,
      );
      expect(find.text('تفاصيل المنتج'), findsOneWidget);
      expect(find.textContaining('يحتوي على فيتامين سي'), findsOneWidget);
      expect(find.textContaining('يشاهدون الآن'), findsOneWidget);
      // The price under the name and the total on the button.
      expect(
        find.descendant(
          of: find.byType(ProductDetailsPage),
          matching: find.text('6.50 د.أ'),
        ),
        findsNWidgets(2),
      );
      expect(find.text('أضف للسلة'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('13.00 د.أ'), findsOneWidget, reason: 'total of two');

      await tester.tap(find.text('أضف للسلة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('تمت إضافة المنتج إلى السلة'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('product-cart')),
          matching: find.byType(CountBadge),
        ),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('the heart marks the product as a favourite', (tester) async {
      await openProduct(tester);
      expect(find.byIcon(Icons.favorite), findsNothing);
      await tester.tap(find.byKey(const ValueKey('product-favorite')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('share opens the sheet and sends the link', (tester) async {
      final opener = RecordingLinkOpener();
      await openProduct(tester, opener: opener);

      await tester.tap(find.byKey(const ValueKey('product-share')));
      await tester.pumpAndSettle();
      expect(find.text('مشاركة من خلال ...'), findsOneWidget);
      for (final target in ShareTarget.values) {
        expect(find.byKey(ValueKey('share-${target.name}')), findsOneWidget);
      }

      await tester.tap(find.byKey(const ValueKey('share-whatsapp')));
      await tester.pumpAndSettle();
      expect(find.text('مشاركة من خلال ...'), findsNothing);
      expect(opener.opened.single.host, 'wa.me');
      expect(
        opener.opened.single.queryParameters['text'],
        contains('drjabel.app/product/$_vitaminC'),
      );
    });

    testWidgets('a failed share says so', (tester) async {
      await openProduct(tester, opener: RecordingLinkOpener(result: false));
      await tester.tap(find.byKey(const ValueKey('product-share')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('share-snapchat')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('تعذّرت المشاركة، تأكد من تثبيت التطبيق'),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('tapping the picture opens the full screen preview', (
      tester,
    ) async {
      await openProduct(tester);
      await tester.tap(find.byType(PageView).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('image-preview-close')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('image-preview-close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('image-preview-close')), findsNothing);
      expect(find.text('تفاصيل المنتج'), findsOneWidget);
    });

    testWidgets('the back button returns to the list', (tester) async {
      await openProduct(tester);
      await tester.tap(find.byKey(const ValueKey('product-back')));
      await tester.pumpAndSettle();
      expect(find.text('تفاصيل المنتج'), findsNothing);
    });
  });
}
