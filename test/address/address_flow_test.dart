import 'package:flutter_svg/flutter_svg.dart';
import 'package:dr_jabel/core/error/exceptions.dart';
import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/widgets/app_button.dart';
import 'package:dr_jabel/features/address/domain/entities/geo_point.dart';
import 'package:dr_jabel/features/address/presentation/pages/map_picker_page.dart';
import 'package:dr_jabel/features/address/presentation/widgets/delivery_options_sheet.dart';
import 'package:dr_jabel/features/address/presentation/widgets/hint_tooltip.dart';
import 'package:dr_jabel/features/address/presentation/widgets/place_search_bar.dart';
import 'package:dr_jabel/features/address/presentation/widgets/sheet_frame.dart';
import 'package:dr_jabel/features/home/presentation/widgets/home_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_map.dart';
import '../helpers/test_app.dart';

const _session = {
  StorageKeys.onboardingSeen: true,
  StorageKeys.authToken: 'mock-token-1',
  StorageKeys.authUser:
      '{"id":"1","name":"Ahmad Ali","phone":"+962791234567","email":null}',
};
const _english = {..._session, StorageKeys.languageCode: 'en'};

const _irbid = GeoPoint(32.5556, 35.8469);

Future<void> _openSheet(WidgetTester tester, String headerText) async {
  await tester.tap(find.textContaining(headerText, findRichText: true).first);
  await tester.pumpAndSettle();
}

/// Fills the address details form (a house) and saves it.
Future<void> _saveDetails(
  WidgetTester tester,
  String saveLabel, {
  String? name,
}) async {
  final fields = find.byType(TextField);
  if (name != null) await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), '12'); // house number
  await tester.enterText(fields.at(2), '0791234567'); // phone
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, saveLabel));
  await tester.pumpAndSettle();
}

Future<void> _confirm(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(FilledButton, label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no address yet: question + hint bubble, tap dismisses', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final line = find.text('أين تريد التوصيل؟');
    expect(line, findsOneWidget);
    expect(tester.getTopRight(line).dx, closeTo(width - 16.w, 1));

    final hint = find.byType(HintTooltip);
    expect(hint, findsOneWidget);
    expect(find.text('لتجربة أفضل وعرض الصيدلية القريبة'), findsOneWidget);
    // hangs under the line from the start edge, over the search field
    expect(tester.getTopRight(hint).dx, closeTo(width - 16.w, 1));
    expect(tester.getSize(hint).width, closeTo(160.w, 1));
    expect(
      tester.getTopLeft(hint).dy,
      lessThan(tester.getBottomLeft(find.byType(HomeSearchField)).dy),
    );

    await tester.tap(hint);
    await tester.pumpAndSettle();
    expect(find.byType(HintTooltip), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('options sheet: three ways to pick a place', (tester) async {
    await pumpApp(tester, _session);
    await _openSheet(tester, 'أين تريد التوصيل؟');

    expect(find.byType(DeliveryOptionsSheet), findsOneWidget);
    expect(find.text('أين تريد التوصيل؟'), findsNWidgets(2)); // line + title
    expect(find.text('ابحث على الخريطة'), findsOneWidget);
    expect(find.text('استخدم الموقع الحالي'), findsOneWidget);
    final add = find.widgetWithText(FilledButton, 'إضافة عنوان جديد');
    expect(add, findsOneWidget);
    expect(tester.getSize(add).height, closeTo(44.h, 0.5));

    // rows: icon + text at the right, chevron at the left
    final rows = find.byType(SheetRow);
    expect(rows, findsNWidgets(2));
    final row = rows.first;
    final icons = find.descendant(of: row, matching: find.byType(SvgPicture));
    final rowCenter = tester.getCenter(row).dx;
    expect(tester.getCenter(icons.first).dx, greaterThan(rowCenter)); // leading
    expect(tester.getCenter(icons.last).dx, lessThan(rowCenter)); // chevron
    expect(tester.takeException(), isNull);
  });

  testWidgets('search on the map -> pick a place -> unsaved location', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    await _openSheet(tester, 'أين تريد التوصيل؟');
    await tester.tap(find.text('ابحث على الخريطة'));
    await tester.pumpAndSettle();

    expect(find.byType(MapPickerPage), findsOneWidget);
    expect(find.byKey(const ValueKey('fake-map')), findsOneWidget);
    // opens on the search field with the keyboard
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode?.hasFocus,
      isTrue,
    );
    // the pin's address (Amman centre) and an enabled confirm button
    expect(find.text('شارع الملك حسين'), findsOneWidget);
    expect(find.text('العبدلي، عمّان'), findsOneWidget);
    expect(find.byType(HintTooltip), findsNothing);
    final confirm = find.widgetWithText(FilledButton, 'تأكيد الموقع');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);

    // search Irbid: suggestions, pick, the map flies there
    await tester.enterText(find.byType(TextField), 'إربد');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('suggestion-irbid')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('suggestion-irbid')));
    await tester.pumpAndSettle();
    expect(find.text('شارع الدفاع'), findsOneWidget);
    expect(find.text('إربد، مدينة الحسن للشباب'), findsOneWidget);
    // outside the delivery area: bubble under the pin, confirm disabled and grey
    expect(
      find.text(
        'نعتذر، التوصيل غير متاح لهذه المنطقة حاليًا. يرجى اختيار موقع آخر',
      ),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.greyWhenDisabled, isTrue);

    // search a place in Amman and confirm it
    await tester.enterText(find.byType(TextField), 'طبربور');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('suggestion-tabarbour')));
    await tester.pumpAndSettle();
    expect(find.text('سهيل بن عمرو'), findsOneWidget);
    expect(find.byType(HintTooltip), findsNothing);
    await _confirm(tester, 'تأكيد الموقع');

    // back on home: delivering to an unsaved location, with its hint
    expect(find.byType(MapPickerPage), findsNothing);
    expect(
      find.textContaining('موقع غير محفوظ', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text(
        'العنوان الذي اخترته مختلف عن موقعك الحالي، هل أنت متأكد من عنوان التوصيل؟',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('add a new address -> saved, delivered to, listed in the sheet', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    await _openSheet(tester, 'أين تريد التوصيل؟');
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة عنوان جديد'));
    await tester.pumpAndSettle();
    expect(find.byType(MapPickerPage), findsOneWidget);
    // adding is not searching: no keyboard
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode?.hasFocus,
      isFalse,
    );

    await _confirm(tester, 'تأكيد الموقع');
    // the details form: named after its type until the customer types a name
    expect(find.text('تفاصيل العنوان'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'البيت',
    );
    await _saveDetails(tester, 'حفظ العنوان', name: 'بيت العائلة');
    expect(find.byType(MapPickerPage), findsNothing);
    // saved: the header names it and the hint is gone
    expect(
      find.textContaining('بيت العائلة', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(HintTooltip), findsNothing);

    // the sheet is now the list of saved addresses
    await _openSheet(tester, 'التوصيل إلى');
    expect(find.text('عناوين التوصيل'), findsOneWidget);
    expect(find.byType(SheetRow), findsOneWidget);
    expect(find.text('بيت العائلة'), findsOneWidget);
    expect(find.textContaining('العبدلي، عمّان'), findsOneWidget);
    expect(find.text('ابحث على الخريطة'), findsNothing);

    // add a second one from the list, then switch back to the first
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة عنوان جديد'));
    await tester.pumpAndSettle();
    FakeMapCanvas.moveTo(const GeoPoint(31.9632, 35.9189));
    await tester.pumpAndSettle();
    expect(find.text('مجمع البواب'), findsOneWidget);
    await _confirm(tester, 'تأكيد الموقع');
    await _saveDetails(tester, 'حفظ العنوان', name: 'المكتب الجديد');
    expect(
      find.textContaining('المكتب الجديد', findRichText: true),
      findsOneWidget,
    );

    await _openSheet(tester, 'المكتب الجديد');
    expect(find.byType(SheetRow), findsNWidgets(2));
    await tester.tap(find.text('بيت العائلة'));
    await tester.pumpAndSettle();
    expect(find.byType(SheetRow), findsNothing); // sheet closed
    expect(
      find.textContaining('بيت العائلة', findRichText: true),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('use current location: unsaved delivery place', (tester) async {
    final device = FakeDeviceLocation(point: const GeoPoint(31.9863, 35.9814));
    await pumpApp(tester, _session, deviceLocation: device);
    await _openSheet(tester, 'أين تريد التوصيل؟');
    await tester.tap(find.text('استخدم الموقع الحالي'));
    await tester.pumpAndSettle();
    expect(device.calls, 1);
    expect(find.byType(SheetRow), findsNothing); // sheet closed
    expect(
      find.textContaining('موقع غير محفوظ', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets(
    'use current location: permission denied is explained in the sheet',
    (tester) async {
      final device = FakeDeviceLocation(
        error: const LocationPermissionException(),
      );
      await pumpApp(tester, _session, deviceLocation: device);
      await _openSheet(tester, 'أين تريد التوصيل؟');
      await tester.tap(find.text('استخدم الموقع الحالي'));
      await tester.pumpAndSettle();
      expect(find.byType(SheetRow), findsNWidgets(2)); // sheet stays open
      expect(
        find.text(
          'لم يتم السماح بالوصول إلى موقعك. فعّل الإذن من إعدادات الجهاز',
        ),
        findsOneWidget,
      );

      device.error = const LocationDisabledException();
      await tester.tap(find.text('استخدم الموقع الحالي'));
      await tester.pumpAndSettle();
      expect(
        find.text('خدمات الموقع متوقفة. فعّلها من إعدادات الجهاز'),
        findsOneWidget,
      );

      // the next time the sheet opens the old error is gone
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await _openSheet(tester, 'أين تريد التوصيل؟');
      expect(find.byKey(const ValueKey('location-error')), findsNothing);
    },
  );

  testWidgets('map page: back closes suggestions first, then the page', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    await _openSheet(tester, 'أين تريد التوصيل؟');
    await tester.tap(find.text('ابحث على الخريطة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'إربد');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('suggestion-irbid')), findsOneWidget);

    final back = find.descendant(
      of: find.byType(PlaceSearchBar),
      matching: find.byType(InkResponse),
    );
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.byType(MapPickerPage), findsOneWidget);
    expect(find.byKey(const ValueKey('suggestion-irbid')), findsNothing);

    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.byType(MapPickerPage), findsNothing);
    // nothing was chosen
    expect(find.text('أين تريد التوصيل؟'), findsOneWidget);

    // no result text for nonsense
    await _openSheet(tester, 'أين تريد التوصيل؟');
    await tester.tap(find.text('ابحث على الخريطة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzzzz');
    await tester.pumpAndSettle();
    expect(find.text('لا توجد نتائج مطابقة'), findsOneWidget);
  });

  testWidgets('map page layout (AR): search bar, pin, panel', (tester) async {
    await pumpApp(tester, _session);
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    await _openSheet(tester, 'أين تريد التوصيل؟');
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة عنوان جديد'));
    await tester.pumpAndSettle();

    // top bar 58pt: back arrow on the right, search field on the left
    expect(
      tester.getSize(find.byType(PlaceSearchBar)).height,
      closeTo(58.h, 0.5),
    );
    final arrow = find.descendant(
      of: find.byType(PlaceSearchBar),
      matching: find.byType(InkResponse),
    );
    expect(tester.getCenter(arrow).dx, greaterThan(width / 2));
    expect(
      tester.getCenter(find.byType(TextField)).dx,
      lessThan(tester.getCenter(arrow).dx),
    );
    expect(find.text('ابحث عن اسم المنطقة أو الشارع'), findsOneWidget);

    // the pin is a 44pt green square centred on the map's width
    final pin = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == const Color(0xFF267B00) &&
          w.constraints?.maxWidth == 44.r,
    );
    expect(pin, findsOneWidget);
    expect(tester.getCenter(pin).dx, closeTo(width / 2, 1));
    final map = tester.getRect(find.byKey(const ValueKey('fake-map')));
    expect(tester.getTopLeft(pin).dy, closeTo(map.center.dy - 11.h, 1));

    // bottom panel: card then a 44pt full-width button with 16pt margins
    final button = find.widgetWithText(FilledButton, 'تأكيد الموقع');
    expect(tester.getSize(button).height, closeTo(44.h, 0.5));
    expect(tester.getTopLeft(button).dx, closeTo(16.w, 1));
    expect(tester.getTopRight(button).dx, closeTo(width - 16.w, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('English: line, sheet, map page and chevrons mirror to LTR', (
    tester,
  ) async {
    await pumpApp(tester, _english);
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final line = find.text('Where do you want it delivered?');
    expect(tester.getTopLeft(line).dx, closeTo(16.w, 1));
    expect(
      find.text('For a better experience and to show the nearest pharmacy'),
      findsOneWidget,
    );
    final hint = find.byType(HintTooltip);
    expect(tester.getTopLeft(hint).dx, closeTo(16.w, 1));

    await _openSheet(tester, 'Where do you want it delivered?');
    final row = find.byType(SheetRow).first;
    final icons = find.descendant(of: row, matching: find.byType(SvgPicture));
    final rowCenter = tester.getCenter(row).dx;
    expect(tester.getCenter(icons.first).dx, lessThan(rowCenter)); // leading
    expect(tester.getCenter(icons.last).dx, greaterThan(rowCenter)); // chevron
    await tester.tap(find.widgetWithText(FilledButton, 'Add a new address'));
    await tester.pumpAndSettle();

    final arrow = find.descendant(
      of: find.byType(PlaceSearchBar),
      matching: find.byType(InkResponse),
    );
    expect(tester.getCenter(arrow).dx, lessThan(width / 2));
    expect(find.text('Search for an area or a street'), findsOneWidget);
    expect(find.text('King Hussein St'), findsOneWidget);
    FakeMapCanvas.moveTo(_irbid);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Sorry, delivery is not available in this area right now. Please choose another location',
      ),
      findsOneWidget,
    );
    FakeMapCanvas.moveTo(const GeoPoint(31.9863, 35.9814));
    await tester.pumpAndSettle();
    await _confirm(tester, 'Confirm location');
    await _saveDetails(tester, 'Save address');
    expect(
      find.textContaining('Deliver to', findRichText: true),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('small phone (iPhone SE): sheets and map page do not overflow', (
    tester,
  ) async {
    for (final prefs in [_session, _english]) {
      await pumpApp(tester, prefs, size: const Size(750, 1334));
      final ar = prefs == _session;
      await _openSheet(
        tester,
        ar ? 'أين تريد التوصيل؟' : 'Where do you want it delivered?',
      );
      expect(tester.takeException(), isNull);
      await tester.tap(
        find.widgetWithText(
          FilledButton,
          ar ? 'إضافة عنوان جديد' : 'Add a new address',
        ),
      );
      await tester.pumpAndSettle();
      FakeMapCanvas.moveTo(_irbid);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
