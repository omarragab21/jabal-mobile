import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/widgets/app_page_header.dart';
import 'package:dr_jabel/features/main/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

const _seen = {StorageKeys.onboardingSeen: true};

Future<void> _type(WidgetTester t, int index, String text) async {
  await t.enterText(find.byType(TextField).at(index), text);
  await t.pump();
}

void main() {
  testWidgets('empty login shows Arabic field errors, nothing is sent', (
    tester,
  ) async {
    await pumpApp(tester, _seen);
    await tester.tap(find.widgetWithText(FilledButton, 'تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.text('رقم الجوال مطلوب'), findsOneWidget);
    expect(find.text('كلمة المرور مطلوبة'), findsOneWidget);
  });

  testWidgets('login layout: RTL, dial-code block + flag on the right', (
    tester,
  ) async {
    await pumpApp(tester, _seen);
    expect(directionOf(tester), TextDirection.rtl);
    final code = tester.getCenter(find.text('+962'));
    final hint = tester.getCenter(find.text('أدخل رقم الجوال ...'));
    expect(code.dx, greaterThan(hint.dx)); // dial code at the start (right)
    // login is where the app starts: no back arrow
    expect(
      find.descendant(
        of: find.byType(AppPageHeader),
        matching: find.byType(InkResponse),
      ),
      findsNothing,
    );
    expect(find.text('تسجيل الدخول'), findsWidgets);
  });

  testWidgets('wrong password -> message; demo account -> OTP -> home', (
    tester,
  ) async {
    await pumpApp(tester, _seen);
    await _type(tester, 0, '0791234567');
    await _type(tester, 1, 'wrongpass');
    await tester.tap(find.widgetWithText(FilledButton, 'تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.text('رقم الجوال أو كلمة المرور غير صحيحة'), findsOneWidget);

    await _type(tester, 1, '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'تسجيل الدخول'));
    await settle(tester);
    expect(find.text('رمز التحقق'), findsOneWidget);
    expect(find.textContaining('0791234567'), findsOneWidget);

    // wrong code -> red message
    await tester.enterText(find.byType(TextField), '1234');
    await settle(tester);
    expect(
      find.text('ولايهمك، يمكن في رقم غلط. جرّب كمان مرة 😊'),
      findsOneWidget,
    );

    // right code -> success, session saved, home
    await tester.enterText(find.byType(TextField), '5991');
    await settle(tester);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNavBar), findsOneWidget); // main screen
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(StorageKeys.authToken), isNotNull);
  });

  testWidgets('saved session skips login on next launch', (tester) async {
    await pumpApp(tester, {
      ..._seen,
      StorageKeys.authToken: 'mock-token-1',
      StorageKeys.authUser:
          '{"id":"1","name":"A","phone":"+962791234567","email":null}',
    });
    expect(find.byType(AppBottomNavBar), findsOneWidget); // main screen
  });

  testWidgets('register: validation, then OTP; login link goes back', (
    tester,
  ) async {
    await pumpApp(tester, _seen);
    await tester.tapOnText(
      find.textRange.ofSubstring('إنشاء حساب', skipOffstage: false),
    );
    await tester.pumpAndSettle();
    expect(find.text('الاسم الكامل'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'إرسال رمز التحقق'));
    await tester.pumpAndSettle();
    expect(find.text('الاسم مطلوب'), findsOneWidget);
    expect(find.text('البريد الإلكتروني مطلوب'), findsOneWidget);

    await _type(tester, 0, 'سارة أحمد');
    await _type(tester, 1, 'sara@example.com');
    await _type(tester, 2, '0771234567');
    await _type(tester, 3, 'Str0ng!Pass#9');
    await tester.tap(find.widgetWithText(FilledButton, 'إرسال رمز التحقق'));
    await settle(tester);
    expect(find.text('رمز التحقق'), findsOneWidget);
  });

  testWidgets('country picker: pinned order, search, selection', (
    tester,
  ) async {
    await pumpApp(tester, _seen);
    await tester.tap(find.text('+962'));
    await tester.pumpAndSettle();
    expect(find.text('اختر الدولة'), findsOneWidget);
    final jo = tester.getTopLeft(find.text('الأردن').last).dy;
    final sa = tester.getTopLeft(find.text('السعودية')).dy;
    final eg = tester.getTopLeft(find.text('مصر')).dy;
    expect(jo < sa && sa < eg, isTrue);

    await tester.enterText(find.byType(TextField).last, 'مصر');
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(ListTile), matching: find.text('مصر')),
    );
    await tester.pumpAndSettle();
    expect(find.text('+20'), findsOneWidget);
    expect(find.text('+962'), findsNothing);
  });

  testWidgets('English: labels translate and the layout flips to LTR', (
    tester,
  ) async {
    await pumpApp(tester, {..._seen, StorageKeys.languageCode: 'en'});
    expect(directionOf(tester), TextDirection.ltr);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    final code = tester.getCenter(find.text('+962'));
    final hint = tester.getCenter(find.text('Enter your phone number ...'));
    expect(code.dx, lessThan(hint.dx)); // dial code now on the left
    expect(
      find.descendant(
        of: find.byType(AppPageHeader),
        matching: find.byType(InkResponse),
      ),
      findsNothing,
    ); // no back arrow
  });

  testWidgets('Arabic digits are converted; OTP boxes fill left to right', (
    tester,
  ) async {
    await pumpApp(tester, _seen);
    await _type(tester, 0, '٠٧٩١٢٣٤٥٦٧');
    expect(find.text('0791234567'), findsOneWidget); // converted while typing
    await _type(tester, 1, '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'تسجيل الدخول'));
    await settle(tester);
    expect(find.text('رمز التحقق'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '1234');
    await settle(tester);
    final first = tester.getCenter(find.text('1').last);
    final last = tester.getCenter(find.text('4').last);
    expect(first.dx, lessThan(last.dx)); // 1 on the left, 4 on the right
  });

  testWidgets('register shows live, specific validation messages', (
    tester,
  ) async {
    await pumpApp(tester, _seen);
    await tester.tapOnText(find.textRange.ofSubstring('إنشاء حساب'));
    await tester.pumpAndSettle();

    await _type(tester, 0, 'Ali99');
    await _type(tester, 1, 'not-an-email');
    await _type(tester, 2, '0701234567'); // Jordan, but not a mobile range
    await _type(tester, 3, 'abc');
    await tester.tap(find.widgetWithText(FilledButton, 'إرسال رمز التحقق'));
    await tester.pumpAndSettle();
    expect(find.text('الاسم يجب أن يحتوي على حروف فقط'), findsOneWidget);
    expect(find.text('البريد الإلكتروني غير صالح'), findsOneWidget);
    expect(find.text('أدخل رقم جوال وليس هاتفًا أرضيًا'), findsOneWidget);
    expect(find.text('كلمة المرور يجب ألا تقل عن 8 أحرف'), findsOneWidget);

    // after the first attempt the messages follow the typing
    await _type(tester, 3, 'abcdefgh');
    expect(find.text('أضف حرفًا كبيرًا (A-Z)'), findsOneWidget);
    await _type(tester, 3, 'Abcdefg1');
    expect(find.text('أضف رمزًا واحدًا على الأقل مثل ! @ #'), findsOneWidget);
    await _type(tester, 3, 'Password1!');
    expect(find.text('كلمة المرور شائعة جدًا، اختر غيرها'), findsOneWidget);
    await _type(tester, 0, 'Sara Ahmed');
    expect(find.text('الاسم يجب أن يحتوي على حروف فقط'), findsNothing);
  });

  testWidgets('selecting a country re-validates the phone for that country', (
    tester,
  ) async {
    await pumpApp(tester, _seen);
    await _type(tester, 0, '0512345678'); // valid in Saudi Arabia, not Jordan
    await tester.tap(find.widgetWithText(FilledButton, 'تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.text('رقم الجوال غير صالح لهذه الدولة'), findsOneWidget);

    await tester.tap(find.text('+962'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.text('السعودية'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('رقم الجوال غير صالح لهذه الدولة'), findsNothing);
  });

  testWidgets('blocked number shows the "account can\'t be used" dialog', (
    tester,
  ) async {
    await pumpApp(tester, _seen);
    await _type(tester, 0, '0780000000');
    await _type(tester, 1, 'whatever1');
    await tester.tap(find.widgetWithText(FilledButton, 'تسجيل الدخول'));
    await settle(tester);

    expect(find.text('لا يمكن إكمال تسجيل الدخول'), findsOneWidget);
    expect(
      find.text('لا يمكن تسجيل الدخول باستخدام هذا الرقم في الوقت الحالي.'),
      findsOneWidget,
    );
    expect(find.text('تواصل مع الدعم'), findsOneWidget);
    // close button sits on the left in Arabic, the title on the right
    final close = tester.getCenter(find.byType(InkWell).last);
    final title = tester.getCenter(find.text('لا يمكن إكمال تسجيل الدخول'));
    expect(close.dx, lessThan(title.dx));
    // 320pt wide card, 40pt button
    final button = tester.getSize(
      find.widgetWithText(FilledButton, 'تواصل مع الدعم'),
    );
    expect(button.height, closeTo(40 * 852 / 812, 1));

    await tester.tap(find.byType(InkWell).last); // X closes it
    await tester.pumpAndSettle();
    expect(find.text('لا يمكن إكمال تسجيل الدخول'), findsNothing);
    expect(find.text('رمز التحقق'), findsNothing); // never reached OTP
  });
}
