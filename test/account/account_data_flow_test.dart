import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/widgets/app_page_header.dart';
import 'package:dr_jabel/features/address/presentation/pages/address_details_page.dart';
import 'package:dr_jabel/features/address/presentation/pages/addresses_page.dart';
import 'package:dr_jabel/features/address/presentation/pages/map_picker_page.dart';
import 'package:dr_jabel/features/address/presentation/widgets/hint_tooltip.dart';
import 'package:dr_jabel/features/payment_cards/presentation/widgets/payment_card_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

const _session = {
  StorageKeys.onboardingSeen: true,
  StorageKeys.authToken: 'mock-token-1',
  StorageKeys.authUser:
      '{"id":"1","name":"Ahmad Ali","phone":"+962791234567","email":"ahmad@example.com"}',
};
const _english = {..._session, StorageKeys.languageCode: 'en'};

Future<void> _openAccount(WidgetTester tester, String tabLabel) async {
  if (find.byType(HintTooltip).evaluate().isNotEmpty) {
    await tester.tap(find.byType(HintTooltip));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text(tabLabel).last);
  await tester.pumpAndSettle();
}

Finder _row(String key) => find.byKey(ValueKey(key));

Future<void> _tapRow(WidgetTester tester, String key) async {
  final row = _row(key);
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

Finder _fields() => find.byType(TextField);

Finder _title(String text) =>
    find.descendant(of: find.byType(AppPageHeader), matching: find.text(text));

Future<void> _back(WidgetTester tester) async {
  await tester.tap(
    find
        .descendant(
          of: find.byType(AppPageHeader),
          matching: find.byType(InkResponse),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> _button(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  group('settings', () {
    Future<void> openSettings(WidgetTester tester, String tab) async {
      await _openAccount(tester, tab);
      await tester.tap(_row('open-settings'));
      await tester.pumpAndSettle();
    }

    testWidgets('rows, notifications switch is saved and announced', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await openSettings(tester, 'حسابي');
      expect(_title('الإعدادات'), findsOneWidget);
      expect(find.text('إعدادات الإشعارات'), findsOneWidget);
      expect(find.text('مفعّلة'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('الوضع الليلي'), findsNothing);
      expect(find.text('حذف حسابي'), findsNothing);

      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('تم إيقاف الإشعارات'), findsOneWidget);
      expect(find.text('غير مفعّلة'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(StorageKeys.notificationsEnabled), isFalse);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('night mode and delete account are not offered', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await openSettings(tester, 'حسابي');
      expect(_row('setting-night-mode'), findsNothing);
      expect(_row('setting-delete'), findsNothing);
      expect(_row('setting-notifications'), findsOneWidget);
      expect(_row('setting-language'), findsOneWidget);
    });

    testWidgets(
      'language opens as a bottom sheet with a handle, not a dialog',
      (tester) async {
        await pumpApp(tester, _session);
        await openSettings(tester, 'حسابي');
        await tester.tap(_row('setting-language'));
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(find.byType(Dialog), findsNothing);
        expect(find.text('لغة التطبيق المفضلة'), findsOneWidget);
      },
    );

    testWidgets(
      'language: choose English and the whole app flips to LTR, saved',
      (tester) async {
        await pumpApp(tester, _session);
        await openSettings(tester, 'حسابي');
        expect(directionOf(tester), TextDirection.rtl);
        await tester.tap(_row('setting-language'));
        await tester.pumpAndSettle();
        expect(find.text('لغة التطبيق المفضلة'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('language-en')));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'تطبيق'));
        await tester.pumpAndSettle();

        expect(directionOf(tester), TextDirection.ltr);
        expect(_title('Settings'), findsOneWidget);
        expect(find.text('English'), findsOneWidget);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(StorageKeys.languageCode), 'en');
      },
    );

    testWidgets('language: applying the same one changes nothing', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await openSettings(tester, 'حسابي');
      await tester.tap(_row('setting-language'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'تطبيق'));
      await tester.pumpAndSettle();
      expect(directionOf(tester), TextDirection.rtl);
      expect(_title('الإعدادات'), findsOneWidget);
    });
  });

  group('payment cards', () {
    Future<void> openCards(WidgetTester tester, String tab) async {
      await _openAccount(tester, tab);
      await _tapRow(tester, 'menu-cards');
    }

    Future<void> addCard(WidgetTester tester) async {
      await _button(tester, 'أضف بطاقة جديدة');
      await tester.enterText(_fields().at(0), '4242424242424242');
      await tester.enterText(_fields().at(1), '1240');
      await tester.enterText(_fields().at(2), '123');
      await tester.pumpAndSettle();
    }

    testWidgets('empty list, then the form checks every field', (tester) async {
      await pumpApp(tester, _session);
      await openCards(tester, 'حسابي');
      expect(_title('بطاقات الدفع'), findsOneWidget);
      expect(find.textContaining('لا توجد بطاقات محفوظة'), findsOneWidget);

      await _button(tester, 'أضف بطاقة جديدة');
      expect(_title('إضافة بطاقة'), findsOneWidget);
      await _button(tester, 'إضافة البطاقة');
      expect(find.text('رقم البطاقة مطلوب'), findsOneWidget);
      expect(find.text('تاريخ الانتهاء مطلوب'), findsOneWidget);
      expect(find.text('رمز الأمان مطلوب'), findsOneWidget);

      await tester.enterText(_fields().at(0), '4242424242424241');
      await tester.enterText(_fields().at(1), '0120');
      await tester.enterText(_fields().at(2), '12');
      await tester.pumpAndSettle();
      expect(find.text('رقم البطاقة غير صحيح'), findsOneWidget);
      expect(find.text('البطاقة منتهية الصلاحية'), findsOneWidget);
      expect(find.text('رمز الأمان من 3 أرقام'), findsOneWidget);
      // the number is grouped while typing
      expect(find.text('4242 4242 4242 4241'), findsOneWidget);
      expect(find.text('01/20'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'add a card -> name it -> it is listed; the number is never stored',
      (tester) async {
        await pumpApp(tester, _session);
        await openCards(tester, 'حسابي');
        await addCard(tester);
        await tester.tap(find.widgetWithText(FilledButton, 'إضافة البطاقة'));
        await tester.pumpAndSettle();

        // the nickname page, with the card on top
        expect(_title('إضافة اسم مستعار'), findsOneWidget);
        expect(find.byType(PaymentCardView), findsOneWidget);
        expect(find.text('VISA'), findsOneWidget);
        expect(find.text('••••  ••••  ••••  4242'), findsOneWidget);
        await tester.enterText(_fields(), 'بطاقة الراتب');
        await tester.pump();
        expect(
          find.text('بطاقة الراتب'),
          findsWidgets,
        ); // shown on the card at once
        await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
        await tester.pumpAndSettle();

        expect(_title('بطاقات الدفع'), findsOneWidget);
        expect(find.byType(PaymentCardView), findsOneWidget);
        expect(find.text('بطاقة الراتب'), findsOneWidget);
        expect(find.textContaining('12/40'), findsOneWidget);
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(StorageKeys.paymentCards)!;
        expect(raw, contains('4242'));
        expect(raw, isNot(contains('4242424242424242')));
        expect(raw, isNot(contains('"123"')));
      },
    );

    testWidgets('the nickname is optional and limited', (tester) async {
      await pumpApp(tester, _session);
      await openCards(tester, 'حسابي');
      await addCard(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'إضافة البطاقة'));
      await tester.pumpAndSettle();
      await tester.enterText(_fields(), 'x' * 21);
      await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
      await tester.pumpAndSettle();
      expect(find.text('الاسم المستعار طويل (الحد 20 حرفاً)'), findsOneWidget);
      await tester.enterText(_fields(), '');
      await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
      await tester.pumpAndSettle();
      expect(_title('بطاقات الدفع'), findsOneWidget); // saved without a name
      expect(find.byType(PaymentCardView), findsOneWidget);
    });

    testWidgets('edit the nickname; delete asks first', (tester) async {
      await pumpApp(tester, _session);
      await openCards(tester, 'حسابي');
      await addCard(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'إضافة البطاقة'));
      await tester.pumpAndSettle();
      await tester.enterText(_fields(), 'القديم');
      await _button(tester, 'حفظ');

      await tester.tap(find.byType(PaymentCardView));
      await tester.pumpAndSettle();
      expect(_title('تعديل الاسم المستعار'), findsOneWidget);
      expect(tester.widget<TextField>(_fields()).controller?.text, 'القديم');
      await tester.enterText(_fields(), 'الجديد');
      await _button(tester, 'حفظ');
      expect(find.text('الجديد'), findsOneWidget);

      await tester.tap(find.byType(PaymentCardView));
      await tester.pumpAndSettle();
      await _button(tester, 'حذف البطاقة');
      expect(find.text('هل أنت متأكد من حذف بطاقتك؟'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'إلغاء'));
      await tester.pumpAndSettle();
      expect(_title('تعديل الاسم المستعار'), findsOneWidget); // still there

      await _button(tester, 'حذف البطاقة');
      await tester.tap(find.widgetWithText(FilledButton, 'نعم، احذف البطاقة'));
      await tester.pumpAndSettle();
      expect(_title('بطاقات الدفع'), findsOneWidget);
      expect(find.byType(PaymentCardView), findsNothing);
      expect(find.textContaining('لا توجد بطاقات محفوظة'), findsOneWidget);
    });

    testWidgets('English: mirrored form and texts', (tester) async {
      await pumpApp(tester, _english);
      await openCards(tester, 'Account');
      expect(_title('Payment cards'), findsOneWidget);
      await _button(tester, 'Add a new card');
      await _button(tester, 'Add card');
      expect(find.text('Card number is required'), findsOneWidget);
      expect(
        find.text('We never keep your full card number or security code.'),
        findsOneWidget,
      );
      // expiry on the left, security code on the right
      expect(
        tester.getCenter(_fields().at(1)).dx,
        lessThan(tester.getCenter(_fields().at(2)).dx),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('addresses', () {
    Future<void> openAddresses(WidgetTester tester, String tab) async {
      await _openAccount(tester, tab);
      await _tapRow(tester, 'menu-addresses');
    }

    /// From the empty list: add one through the map and the form.
    Future<void> addAddress(WidgetTester tester, {String? name}) async {
      await _button(tester, 'إضافة عنوان جديد');
      expect(find.byType(MapPickerPage), findsOneWidget);
      await _button(tester, 'تأكيد الموقع');
      expect(find.byType(AddressDetailsPage), findsOneWidget);
      if (name != null) await tester.enterText(_fields().at(0), name);
      await tester.enterText(_fields().at(1), '12');
      await tester.enterText(_fields().at(2), '0791234567');
      await tester.pumpAndSettle();
      await _button(tester, 'حفظ العنوان');
    }

    testWidgets('empty, then add through the map and the details form', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await openAddresses(tester, 'حسابي');
      expect(find.byType(AddressesPage), findsOneWidget);
      expect(_title('عناوين التوصيل'), findsOneWidget);
      expect(find.textContaining('لا توجد عناوين محفوظة'), findsOneWidget);

      await addAddress(tester, name: 'بيتي');
      // back on the list (the form and the map are closed)
      expect(find.byType(AddressesPage), findsOneWidget);
      expect(find.byType(MapPickerPage), findsNothing);
      expect(find.text('بيتي'), findsOneWidget);
      expect(find.textContaining('العبدلي، عمّان'), findsOneWidget);
      expect(find.textContaining('+962791234567'), findsOneWidget);
      expect(find.text('الحالي'), findsOneWidget); // it is where orders go
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StorageKeys.addresses), contains('"unit":"12"'));
    });

    testWidgets('the form: type changes the fields and the default name', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await openAddresses(tester, 'حسابي');
      await _button(tester, 'إضافة عنوان جديد');
      await _button(tester, 'تأكيد الموقع');
      expect(
        tester.widget<TextField>(_fields().at(0)).controller?.text,
        'البيت',
      );
      expect(find.text('رقم البيت'), findsWidgets);
      expect(find.text('الطابق'), findsNothing);

      await tester.tap(find.text('شقة'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(_fields().at(0)).controller?.text,
        'الشقة',
      );
      expect(find.text('اسم المبنى'), findsWidgets);
      expect(find.text('الطابق'), findsWidgets);
      expect(find.text('رقم الشقة'), findsWidgets);

      await tester.tap(find.text('أخرى'));
      await tester.pumpAndSettle();
      expect(find.text('وصف المكان'), findsWidgets);
      expect(find.text('الطابق'), findsNothing);

      // required fields are told on the first try
      await _button(tester, 'حفظ العنوان');
      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
      expect(find.text('رقم الجوال مطلوب'), findsOneWidget);
      expect(find.byType(AddressDetailsPage), findsOneWidget);
    });

    testWidgets('edit an address: prefilled, saved, and the header follows', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await openAddresses(tester, 'حسابي');
      await addAddress(tester, name: 'بيتي');

      await tester.tap(_row('address-${_firstAddressId(tester)}'));
      await tester.pumpAndSettle();
      expect(find.byType(AddressDetailsPage), findsOneWidget);
      expect(
        tester.widget<TextField>(_fields().at(0)).controller?.text,
        'بيتي',
      );
      expect(tester.widget<TextField>(_fields().at(1)).controller?.text, '12');
      expect(
        tester.widget<TextField>(_fields().at(2)).controller?.text,
        '791234567',
      );
      await tester.enterText(_fields().at(0), 'بيت جدي');
      await _button(tester, 'حفظ العنوان');
      expect(find.byType(AddressesPage), findsOneWidget);
      expect(find.text('بيت جدي'), findsOneWidget);
      expect(find.text('بيتي'), findsNothing);

      // the home header shows the new name
      await _back(tester);
      await tester.tap(find.text('الرئيسية').last);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('بيت جدي', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('delete asks first and clears the delivery place', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await openAddresses(tester, 'حسابي');
      await addAddress(tester, name: 'بيتي');
      await tester.tap(_row('address-${_firstAddressId(tester)}'));
      await tester.pumpAndSettle();
      await _button(tester, 'حذف العنوان');
      expect(find.text('هل أنت متأكد من حذف العنوان؟'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'إلغاء'));
      await tester.pumpAndSettle();
      expect(find.byType(AddressDetailsPage), findsOneWidget);

      await _button(tester, 'حذف العنوان');
      await tester.tap(find.widgetWithText(FilledButton, 'نعم، احذف العنوان'));
      await tester.pumpAndSettle();
      expect(find.byType(AddressesPage), findsOneWidget);
      expect(find.text('بيتي'), findsNothing);
      expect(find.textContaining('لا توجد عناوين محفوظة'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StorageKeys.deliverySelection), isNull);
    });

    testWidgets('English: details form is mirrored', (tester) async {
      await pumpApp(tester, _english);
      await _openAccount(tester, 'Account');
      await _tapRow(tester, 'menu-addresses');
      await _button(tester, 'Add a new address');
      await _button(tester, 'Confirm location');
      expect(_title('Address details'), findsOneWidget);
      expect(
        tester.widget<TextField>(_fields().at(0)).controller?.text,
        'My Home',
      );
      expect(find.text('House number'), findsWidgets);
      expect(find.text('Notes for the courier (optional)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// The id of the one saved address, read from the list's row key.
String _firstAddressId(WidgetTester tester) {
  final key =
      tester
              .widgetList(
                find.byWidgetPredicate(
                  (w) =>
                      w.key is ValueKey<String> &&
                      (w.key! as ValueKey<String>).value.startsWith('address-'),
                ),
              )
              .first
              .key!
          as ValueKey<String>;
  return key.value.substring('address-'.length);
}
