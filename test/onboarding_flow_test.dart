import 'dart:convert';
import 'dart:io';

import 'package:dr_jabel/core/localization/app_localization.dart';
import 'package:dr_jabel/core/localization/locale_service.dart';
import 'package:dr_jabel/core/storage/shared_prefs_storage.dart';
import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/features/auth/data/datasources/mock_auth_remote_data_source.dart';
import 'package:dr_jabel/main.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads the real translation files straight from disk (no async asset I/O).
class _FileLoader extends AssetLoader {
  const _FileLoader();
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}

const _p1 = 'صيدليتك أقرب مما تتخيل';
const _p1En = 'Your pharmacy is closer than you think';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object> prefs, {
  Size size = const Size(1179, 2556),
  FakeViewPadding safe = FakeViewPadding.zero,
}) async {
  tester.view.physicalSize = size; // default: iPhone 14 Pro 393x852 @3x
  tester.view.devicePixelRatio = 3;
  tester.view.padding = safe;
  tester.view.viewPadding = safe;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);
  await EasyLocalization.ensureInitialized();
  final storage = await SharedPrefsStorage.create();
  final service = LocaleService(storage);
  await tester.pumpWidget(
    AppLocalization.wrap(
      startLocale: service.load(),
      assetLoader: const _FileLoader(),
      child: MyApp(
        router: buildAppRouter(
          storage,
          authRemote: MockAuthRemoteDataSource(latency: Duration.zero),
        ),
        localeService: service,
      ),
    ),
  );
  await _settle(tester);
  await tester.pump(const Duration(seconds: 3));
  await _settle(tester);
}

/// Translation files load through real async I/O, so give them real time.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pumpAndSettle();
}

TextDirection _dir(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(Scaffold).first));

void main() {
  testWidgets('first launch: Arabic + RTL; skip -> login and remembered', (
    tester,
  ) async {
    await _pump(tester, {});
    expect(find.text(_p1), findsOneWidget);
    expect(_dir(tester), TextDirection.rtl);

    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الدخول'), findsWidgets);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(StorageKeys.onboardingSeen), isTrue);
  });

  testWidgets('already seen: splash -> login (no session)', (tester) async {
    await _pump(tester, {StorageKeys.onboardingSeen: true});
    expect(find.text('تسجيل الدخول'), findsWidgets);
  });

  testWidgets('next goes through 3 pages then finishes to login', (
    tester,
  ) async {
    await _pump(tester, {});
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('ارفع وصفتك في ثوانٍ'), findsOneWidget);
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('دواؤك في موعده دائمًا'), findsOneWidget);
    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الدخول'), findsWidgets);
  });

  testWidgets('English button switches to English + LTR and is saved', (
    tester,
  ) async {
    await _pump(tester, {});
    final skipArabic = tester.getCenter(find.text('تخطي'));
    expect(skipArabic.dx, greaterThan(196)); // Arabic: skip on the right

    await tester.tap(find.text('English'));
    await _settle(tester);
    expect(find.text(_p1En), findsOneWidget);
    expect(_dir(tester), TextDirection.ltr);
    expect(tester.getCenter(find.text('Skip')).dx, lessThan(196)); // left
    expect(find.text('العربية'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(StorageKeys.languageCode), 'en');

    await tester.tap(find.text('العربية'));
    await _settle(tester);
    expect(find.text(_p1), findsOneWidget);
    expect(_dir(tester), TextDirection.rtl);
  });

  testWidgets('saved English is used on next launch', (tester) async {
    await _pump(tester, {StorageKeys.languageCode: 'en'});
    expect(find.text(_p1En), findsOneWidget);
    expect(_dir(tester), TextDirection.ltr);
  });

  for (final c in [
    ('iPhone 14 Pro', const Size(1179, 2556), 393.0, 852.0), // safe 59 / 34
    ('iPhone X (Figma frame)', const Size(1125, 2436), 375.0, 812.0),
    ('small phone', const Size(960, 1920), 320.0, 640.0),
  ]) {
    testWidgets('layout matches Figma sizes: ${c.$1}', (tester) async {
      await _pump(
        tester,
        {},
        size: c.$2,
        safe: c.$1 == 'iPhone 14 Pro'
            ? const FakeViewPadding(top: 177, bottom: 102) // 59/34 @3x
            : FakeViewPadding.zero,
      );
      final img = tester.getSize(find.byType(Image).first);
      final btn = tester.getRect(find.byType(FilledButton));
      final title = tester.getRect(find.text(_p1));
      // ignore: avoid_print
      print(
        '${c.$1}: image=${img.width.toStringAsFixed(1)}x'
        '${img.height.toStringAsFixed(1)} btn=${btn.width.toStringAsFixed(1)}x'
        '${btn.height.toStringAsFixed(1)} titleTop=${title.top.toStringAsFixed(1)}'
        ' btnBottom=${btn.bottom.toStringAsFixed(1)}',
      );
      if (c.$1.startsWith('iPhone X')) {
        // exact Figma numbers at the design frame (375 x 812)
        expect(img.width, 343);
        expect(img.height, 320);
        expect(btn.width, 310);
        expect(btn.height, 44);
      }
      expect(tester.takeException(), isNull);
      // image spans the screen minus 16 margins each side (scaled)
      expect(img.width, closeTo(c.$3 - 32 * c.$3 / 375, 1));
      // content stays inside the screen, button above bottom safe area
      expect(btn.bottom, lessThan(c.$4));
    });
  }
}
