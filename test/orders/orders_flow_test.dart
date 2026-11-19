import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _session = {
  StorageKeys.onboardingSeen: true,
  StorageKeys.authToken: 'mock-token-1',
  StorageKeys.authUser:
      '{"id":"1","name":"Ahmad Ali","phone":"+962791234567","email":null}',
};

Future<void> _openOrdersTab(WidgetTester tester) async {
  await pumpApp(tester, _session);
  await tester.tap(find.text('طلباتي'));
  await tester.pumpAndSettle();
}

/// The details page is a lazy list: scroll until the widget exists, then
/// bring it fully on screen.
Future<void> _scrollTo(
  WidgetTester tester,
  Finder finder, {
  double delta = 300,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.ensureVisible(finder);
}

void main() {
  testWidgets('current and previous tabs list the mock orders', (tester) async {
    await _openOrdersTab(tester);

    expect(find.text('الطلبات الحالية'), findsOneWidget);
    expect(find.text('ORD-2026-001'), findsOneWidget);
    expect(find.text('قيد المراجعة'), findsOneWidget);
    expect(find.text('تم التسليم'), findsNothing);

    await tester.tap(find.text('الطلبات السابقة'));
    await tester.pumpAndSettle();
    expect(find.text('ORD-2026-005'), findsOneWidget);
    expect(find.text('تم التسليم'), findsOneWidget);
    expect(find.text('ملغي'), findsWidgets);
    expect(find.text('ORD-2026-001'), findsNothing);
  });

  testWidgets('a pending order can be cancelled from its details', (
    tester,
  ) async {
    await _openOrdersTab(tester);

    await tester.tap(find.text('ORD-2026-001'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل الطلب'), findsOneWidget);
    expect(find.text('بانتظار الموافقة على طلبك'), findsOneWidget);

    await _scrollTo(tester, find.text('إلغاء الطلب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إلغاء الطلب'));
    // Not pumpAndSettle: the countdown keeps scheduling frames.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('هل أنت متأكد من إلغاء الطلب؟'), findsOneWidget);
    expect(find.text('متبقي للإلغاء: 00:45'), findsOneWidget);

    // The red button of the sheet confirms.
    await tester.tap(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.text('إلغاء الطلب'),
      ),
    );
    // Check the toast before pumpAndSettle waits for it to go away.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text('تم إلغاء الطلب و إعادة المبلغ إلى المحفظة بنجاح'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    // The banner is at the top, out of the lazy list's reach: scroll back up.
    await _scrollTo(
      tester,
      find.text('تم إلغاء الطلب بناءً على طلبك بنجاح'),
      delta: -300,
    );
    expect(find.text('تم إلغاء الطلب بناءً على طلبك بنجاح'), findsOneWidget);
  });

  testWidgets('a delivered order opens its tax invoice', (tester) async {
    await _openOrdersTab(tester);
    await tester.tap(find.text('الطلبات السابقة'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ORD-2026-005'));
    await tester.pumpAndSettle();
    expect(find.text('وصل طلبك، نتمنى لك لحظات سعيدة!'), findsOneWidget);

    await _scrollTo(tester, find.text('عرض الفاتورة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عرض الفاتورة'));
    await tester.pumpAndSettle();

    expect(find.text('فاتورة ضريبية'), findsOneWidget);
    expect(find.text('Hussein Zarour'), findsOneWidget);
  });
}
