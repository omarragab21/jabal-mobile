import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/widgets/count_badge.dart';
import 'package:dr_jabel/features/checkout/presentation/pages/checkout_page.dart';
import 'package:dr_jabel/features/legal/domain/entities/legal_document.dart';
import 'package:dr_jabel/features/legal/presentation/pages/legal_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _session = {
  StorageKeys.onboardingSeen: true,
  StorageKeys.authToken: 'mock-token-1',
  StorageKeys.authUser:
      '{"id":"1","name":"Ahmad Ali","phone":"+962791234567","email":null}',
};

const _withAddress = {
  ..._session,
  StorageKeys.addresses:
      '[{"id":"a1","title":"البيت","details":"32, سهيل بن عمرو, طبربور",'
      '"lat":31.95,"lng":35.91,"type":"house","phone":"079XXXXXXX"}]',
  StorageKeys.deliverySelection:
      '{"lat":31.95,"lng":35.91,"label":"البيت",'
      '"details":"32, سهيل بن عمرو, طبربور","addressId":"a1"}',
};

const _vitaminC = 104; // 6.50

Finder _inCart(Finder f) => find.descendant(
  of: find.byKey(const ValueKey('cart-item-$_vitaminC')),
  matching: f,
);

/// Lazy lists only build what is near the screen: drag the checkout's list
/// until [finder] exists, then bring it fully into view.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final list = find
      .descendant(
        of: find.byType(CheckoutPage),
        matching: find.byType(Scrollable),
      )
      .first;
  if (finder.evaluate().isEmpty) {
    // Start from the top: the target may be above what is built now.
    await tester.drag(list, const Offset(0, 3000));
    await tester.pumpAndSettle();
  }
  for (var i = 0; i < 30 && finder.evaluate().isEmpty; i++) {
    await tester.drag(list, const Offset(0, -200));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

/// From the home page: open vitamin C, add [times] to the cart, go back.
Future<void> _addVitaminC(WidgetTester tester, {int times = 1}) async {
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
  for (var i = 1; i < times; i++) {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('أضف للسلة'));
  // The toast sits over the header until it has slid away.
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('product-back')));
  await tester.pumpAndSettle();
}

Future<void> _openCartTab(WidgetTester tester) async {
  await tester.tap(find.text('السلة').last);
  await tester.pumpAndSettle();
}

/// The header's back arrow of the page on top.
Future<void> _back(WidgetTester tester) async {
  await tester.tap(find.byType(InkResponse).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an empty cart invites to the products', (tester) async {
    await pumpApp(tester, _session);
    await _openCartTab(tester);

    expect(find.text('السلة فارغة'), findsOneWidget);
    expect(find.text('عند إضافة المنتجات ستظهر هنا'), findsOneWidget);

    await tester.tap(find.text('اكتشف المنتجات'));
    await tester.pumpAndSettle();
    expect(
      find.text('السلة فارغة'),
      findsNothing,
      reason: 'back on the home tab',
    );
  });

  testWidgets('what is added shows in the cart and can be changed', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    await _addVitaminC(tester);
    await _openCartTab(tester);

    expect(find.text('عدد المنتجات: 1'), findsOneWidget);
    expect(
      _inCart(find.text('فيتامين سي 1000 مجم أقراص فوارة بنكهة البرتقال')),
      findsOneWidget,
    );
    expect(_inCart(find.text('20 قرصًا')), findsOneWidget);
    expect(find.byKey(const ValueKey('cart-subtotal')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('cart-subtotal'))).data,
      '6.50 د.أ',
    );

    // With one piece the minus is a bin; one more makes two.
    expect(
      _inCart(find.byKey(const ValueKey('stepper-decrement'))),
      findsOneWidget,
    );
    await tester.tap(_inCart(find.byKey(const ValueKey('stepper-increment'))));
    await tester.pumpAndSettle();
    expect(find.text('عدد المنتجات: 2'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('cart-subtotal'))).data,
      '13.00 د.أ',
    );
    expect(
      _inCart(find.byKey(const ValueKey('stepper-decrement'))),
      findsOneWidget,
    );

    // Back to one, then the bin empties the cart.
    await tester.tap(_inCart(find.byKey(const ValueKey('stepper-decrement'))));
    await tester.pumpAndSettle();
    await tester.tap(_inCart(find.byKey(const ValueKey('stepper-decrement'))));
    await tester.pumpAndSettle();
    expect(find.text('السلة فارغة'), findsOneWidget);
  });

  testWidgets('the pencil opens the product to update its quantity', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    await _addVitaminC(tester, times: 2);
    await _openCartTab(tester);
    expect(find.text('عدد المنتجات: 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cart-edit')));
    await tester.pumpAndSettle();
    expect(find.text('تحديث'), findsOneWidget, reason: 'update, not add');

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تحديث'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('تم تحديث السلة'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('عدد المنتجات: 3'), findsOneWidget);
  });

  testWidgets('checkout: address, code, wallet, then a cash order', (
    tester,
  ) async {
    await pumpApp(tester, _withAddress);
    await _addVitaminC(tester, times: 2);
    await _openCartTab(tester);

    await tester.tap(find.text('المتابعة لإتمام الطلب'));
    await tester.pumpAndSettle();

    // The delivery address comes from the saved ones.
    expect(find.text('عنوان التوصيل'), findsOneWidget);
    expect(find.text('البيت'), findsOneWidget);
    expect(find.textContaining('079XXXXXXX'), findsOneWidget);
    expect(find.text('2 منتجات'), findsOneWidget);

    // 13.00 + 2.00 delivery.
    final total = find.descendant(
      of: find.byKey(const ValueKey('price-total')),
      matching: find.textContaining('د.أ'),
    );
    Future<String> payable() async {
      await _reveal(tester, find.byKey(const ValueKey('price-total')));
      return tester.widget<Text>(total).data!;
    }

    expect(await payable(), '15.00 د.أ');

    // A wrong code is refused, a good one takes 10% off the products.
    await _reveal(tester, find.byKey(const ValueKey('promo-field')));
    await tester.enterText(find.byKey(const ValueKey('promo-field')), 'nope');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('promo-apply')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('promo-invalid')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('promo-field')),
      'Jabal2026',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('promo-apply')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('promo-applied')), findsOneWidget);
    expect(await payable(), '13.70 د.أ');

    // The wallet (12.50) pays most of it.
    await _reveal(tester, find.byKey(const ValueKey('wallet-switch')));
    await tester.tap(find.byKey(const ValueKey('wallet-switch')));
    await tester.pumpAndSettle();
    expect(await payable(), '1.20 د.أ');

    // Cash on delivery is the default method: confirm.
    await tester.tap(find.byKey(const ValueKey('confirm-order')));
    await tester.pumpAndSettle();
    expect(find.text('تم تأكيد الطلب ✅'), findsOneWidget);
    expect(find.byKey(const ValueKey('placed-order-number')), findsOneWidget);

    await tester.tap(find.text('العودة للرئيسية'));
    await tester.pumpAndSettle();

    // Home again, and the cart is empty.
    expect(find.text('تم تأكيد الطلب ✅'), findsNothing);
    expect(find.byType(CountBadge), findsNothing);
    await _openCartTab(tester);
    expect(find.text('السلة فارغة'), findsOneWidget);
  });

  testWidgets('paying with Apple Pay goes through the gateway page', (
    tester,
  ) async {
    await pumpApp(tester, _withAddress);
    await _addVitaminC(tester);
    await _openCartTab(tester);
    await tester.tap(find.text('المتابعة لإتمام الطلب'));
    await tester.pumpAndSettle();

    await _reveal(tester, find.byKey(const ValueKey('method-apple-pay')));
    await tester.tap(find.byKey(const ValueKey('method-apple-pay')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-order')));
    await tester.pumpAndSettle();

    expect(find.text('صفحة بوابة الدفع الإلكتروني'), findsOneWidget);

    // A cancelled payment comes back with an error and keeps the cart.
    await tester.tap(find.byKey(const ValueKey('gateway-cancel')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('تعذّر إتمام الطلب، حاول مرة أخرى'), findsOneWidget);
    await tester.pumpAndSettle();

    // Trying again and paying places the order.
    await tester.tap(find.byKey(const ValueKey('confirm-order')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('gateway-pay')));
    await tester.pumpAndSettle();
    expect(find.text('تم تأكيد الطلب ✅'), findsOneWidget);
  });

  testWidgets('each link under confirm opens its own document', (tester) async {
    await pumpApp(tester, _withAddress);
    await _addVitaminC(tester);
    await _openCartTab(tester);
    await tester.tap(find.text('المتابعة لإتمام الطلب'));
    await tester.pumpAndSettle();

    LegalDocumentType shown() =>
        tester.widget<LegalDocumentPage>(find.byType(LegalDocumentPage)).type;

    await tester.tapOnText(find.textRange.ofSubstring('الشروط والأحكام'));
    await tester.pumpAndSettle();
    expect(find.byType(PoliciesPage), findsNothing, reason: 'not the list');
    expect(shown(), LegalDocumentType.terms);

    await _back(tester);
    await tester.tapOnText(find.textRange.ofSubstring('سياسة الخصوصية'));
    await tester.pumpAndSettle();
    expect(find.byType(PoliciesPage), findsNothing);
    expect(shown(), LegalDocumentType.privacy);

    await _back(tester);
    expect(find.byKey(const ValueKey('confirm-order')), findsOneWidget);
  });

  testWidgets('without an address nothing can be confirmed', (tester) async {
    await pumpApp(tester, _session);
    await _addVitaminC(tester);
    await _openCartTab(tester);
    await tester.tap(find.text('المتابعة لإتمام الطلب'));
    await tester.pumpAndSettle();

    expect(find.text('اختر عنوان التوصيل'), findsOneWidget);
    final confirm = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const ValueKey('confirm-order')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(confirm.onPressed, isNull);
  });
}
