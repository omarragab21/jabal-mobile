import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/features/main/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:dr_jabel/features/home/presentation/pages/home_page.dart';
import 'package:dr_jabel/core/widgets/count_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

const _session = {
  StorageKeys.onboardingSeen: true,
  StorageKeys.authToken: 'mock-token-1',
  StorageKeys.authUser:
      '{"id":"1","name":"Ahmad Ali","phone":"+962791234567","email":null}',
};

double _x(WidgetTester t, String label) =>
    t.getCenter(find.text(label).last).dx;

void main() {
  testWidgets(
    'five tabs in Arabic order (home on the right), empty cart has no badge',
    (tester) async {
      await pumpApp(tester, _session);
      expect(find.byType(AppBottomNavBar), findsOneWidget);

      final order = ['الرئيسية', 'الأقسام', 'السلة', 'طلباتي', 'حسابي'];
      final xs = order.map((l) => _x(tester, l)).toList();
      for (var i = 0; i < xs.length - 1; i++) {
        expect(
          xs[i],
          greaterThan(xs[i + 1]),
          reason: '${order[i]} is right of ${order[i + 1]}',
        );
      }
      expect(find.byType(CountBadge), findsNothing);

      // 70pt bar (+1pt border) scaled from the 375x812 design frame
      final h = tester.getSize(find.byType(AppBottomNavBar)).height;
      expect(h, closeTo(70 * 852 / 812 + 1, 1));
    },
  );

  testWidgets('tapping a tab switches the page and keeps the others alive', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    // the home page has no title, only its content
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('طلباتي'), findsOneWidget); // label only

    await tester.tap(find.text('طلباتي'));
    await tester.pumpAndSettle();
    expect(find.text('طلباتي'), findsNWidgets(2)); // label + page title

    await tester.tap(find.text('السلة'));
    await tester.pumpAndSettle();
    expect(find.text('السلة'), findsNWidgets(2));
    await tester.tap(find.text('الأقسام'));
    await tester.pumpAndSettle();
    expect(find.text('الأقسام'), findsNWidgets(2));
  });

  testWidgets('selected tab is green with a top bar, others are grey', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    Color? labelColor(String t) =>
        tester.widget<Text>(find.text(t).last).style?.color;
    expect(labelColor('الرئيسية'), const Color(0xFF267B00));
    expect(labelColor('السلة'), const Color(0xFF344054));
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    expect(labelColor('حسابي'), const Color(0xFF267B00));
    expect(labelColor('الرئيسية'), const Color(0xFF344054));
  });

  testWidgets('English: labels translate and the bar order flips to LTR', (
    tester,
  ) async {
    await pumpApp(tester, {..._session, StorageKeys.languageCode: 'en'});
    final order = ['Home', 'Categories', 'Cart', 'My orders', 'Account'];
    final xs = order.map((l) => _x(tester, l)).toList();
    for (var i = 0; i < xs.length - 1; i++) {
      expect(xs[i], lessThan(xs[i + 1]), reason: order[i]);
    }
  });

  testWidgets('account logs out to the login screen', (tester) async {
    await pumpApp(tester, _session);
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    expect(find.text('Ahmad Ali'), findsNothing);
    expect(find.text('+962791234567'), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, 'تسجيل الخروج'));
    await settle(tester);
    expect(find.byType(AppBottomNavBar), findsNothing);
    expect(find.widgetWithText(FilledButton, 'تسجيل الدخول'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(StorageKeys.authToken), isNull);
  });
}
