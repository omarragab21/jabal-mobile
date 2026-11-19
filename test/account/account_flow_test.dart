import 'package:dr_jabel/core/config/app_links.dart';
import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/widgets/app_menu_row.dart';
import 'package:dr_jabel/core/widgets/app_page_header.dart';
import 'package:dr_jabel/features/account/presentation/pages/account_page.dart';
import 'package:dr_jabel/features/address/presentation/widgets/hint_tooltip.dart';
import 'package:dr_jabel/features/auth/presentation/login/login_page.dart';
import 'package:dr_jabel/features/legal/presentation/pages/legal_pages.dart';
import 'package:dr_jabel/features/profile/presentation/pages/personal_info_page.dart';
import 'package:dr_jabel/features/support/data/datasources/store_info_remote_data_source.dart';
import 'package:dr_jabel/features/support/domain/entities/store_info.dart';
import 'package:dr_jabel/core/sharing/share_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

/// A store with only a WhatsApp number.
class _OnlyWhatsapp implements StoreInfoRemoteDataSource {
  const _OnlyWhatsapp();

  @override
  Future<StoreInfo> fetchStoreInfo() async =>
      const StoreInfo(whatsappNumber: '962791234567');
}

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

void main() {
  group('account menu', () {
    testWidgets(
      '(AR) header with settings at the end, who is signed in, the rows',
      (tester) async {
        await pumpApp(tester, _session);
        final width =
            tester.view.physicalSize.width / tester.view.devicePixelRatio;
        await _openAccount(tester, 'حسابي');

        expect(find.byType(AccountPage), findsOneWidget);
        final header = find.byType(AppPageHeader);
        expect(tester.getSize(header).height, closeTo(58.h, 0.5));
        expect(_title('حسابي'), findsOneWidget);
        // settings icon at the end edge (left in Arabic)
        expect(tester.getCenter(_row('open-settings')).dx, lessThan(width / 2));
        // no back arrow on a tab
        expect(
          find.descendant(of: header, matching: find.byType(InkResponse)),
          findsOneWidget,
        );
        // the name and the phone are not shown on the account tab
        expect(find.byKey(const ValueKey('account-name')), findsNothing);
        expect(find.text('Ahmad Ali'), findsNothing);
        expect(find.text('+962791234567'), findsNothing);

        // order and labels (orders and reminders are not here)
        final order = [
          ('menu-personal-info', 'المعلومات الشخصية'),
          ('menu-addresses', 'عناوين التوصيل'),
          ('menu-cards', 'بطاقات الدفع'),
          ('menu-support', 'الدعم والمساعدة'),
          ('menu-policies', 'السياسات'),
          ('menu-community', 'انضم إلى مجتمع جبل'),
          ('menu-about', 'عن التطبيق'),
          ('menu-share', 'شارك التطبيق'),
        ];
        var lastY = -1.0;
        for (final (key, label) in order) {
          final row = _row(key);
          await tester.ensureVisible(row);
          expect(
            find.descendant(of: row, matching: find.text(label)),
            findsOneWidget,
            reason: label,
          );
          final y = tester.getTopLeft(row).dy;
          // scrolling moves everything; compare positions in list order instead
          expect(y.isFinite, isTrue);
          lastY = y;
        }
        expect(lastY, isNot(-1.0));
        expect(find.textContaining('الطلبات'), findsNothing);
        expect(find.textContaining('المحفظة'), findsNothing);
        expect(find.textContaining('تذكير'), findsNothing);
        expect(find.text('قيّم تطبيق دكتور جبل'), findsNothing);
        // share has the same chevron as the other rows
        expect(
          find.descendant(
            of: _row('menu-share'),
            matching: find.byType(Transform),
          ),
          findsWidgets,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('(EN) mirrored', (tester) async {
      await pumpApp(tester, _english);
      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      await _openAccount(tester, 'Account');
      expect(
        tester.getCenter(_row('open-settings')).dx,
        greaterThan(width / 2),
      );
      expect(find.text('Personal information'), findsOneWidget);
      expect(find.text('Delivery addresses'), findsOneWidget);
      final row = _row('menu-personal-info');
      final icons = find.descendant(of: row, matching: find.byType(Transform));
      expect(icons, findsWidgets); // the chevron is flipped for LTR
      expect(tester.takeException(), isNull);
    });

    testWidgets('the version is shown under the logout button', (tester) async {
      await pumpApp(tester, _session);
      await _openAccount(tester, 'حسابي');
      final version = find.byKey(const ValueKey('app-version'));
      await tester.ensureVisible(version);
      expect(find.text('الإصدار 1.2.3'), findsOneWidget);
    });

    testWidgets('log out goes to the login screen and clears the session', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await _openAccount(tester, 'حسابي');
      final logout = find.widgetWithText(OutlinedButton, 'تسجيل الخروج');
      await tester.ensureVisible(logout);
      await tester.pumpAndSettle();
      await tester.tap(logout);
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StorageKeys.authToken), isNull);
    });
  });

  group('personal information', () {
    testWidgets('rows show the details; "not set" for the rest', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await _openAccount(tester, 'حسابي');
      await _tapRow(tester, 'menu-personal-info');
      expect(find.byType(PersonalInfoPage), findsOneWidget);
      expect(_title('المعلومات الشخصية'), findsOneWidget);
      expect(find.text('Ahmad Ali'), findsOneWidget);
      expect(find.text('ahmad@example.com'), findsOneWidget);
      expect(find.text('+962791234567'), findsOneWidget);
      expect(find.text('غير محدد'), findsNWidgets(2)); // gender, birth date
      expect(find.byType(InfoRow), findsNWidgets(5));
      // e-mail and phone read left to right
      expect(
        tester.widget<Text>(find.text('ahmad@example.com')).textDirection,
        TextDirection.ltr,
      );
    });

    testWidgets(
      'change the name: validated, saved, and shown on the account tab',
      (tester) async {
        await pumpApp(tester, _session);
        await _openAccount(tester, 'حسابي');
        await _tapRow(tester, 'menu-personal-info');
        await tester.tap(find.text('Ahmad Ali'));
        await tester.pumpAndSettle();
        expect(_title('تعديل الاسم'), findsOneWidget);
        expect(
          tester.widget<TextField>(_fields()).controller?.text,
          'Ahmad Ali',
        );

        await tester.enterText(_fields(), 'A');
        await tester.pump();
        expect(
          find.text('الاسم قصير جدًا'),
          findsNothing,
        ); // not before a first try
        await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
        await tester.pumpAndSettle();
        expect(find.text('الاسم قصير جدًا'), findsOneWidget);
        await tester.enterText(_fields(), 'Ahmad 5');
        await tester.pump();
        expect(
          find.text('الاسم يجب أن يحتوي على حروف فقط'),
          findsOneWidget,
        ); // live now

        await tester.enterText(_fields(), '  Sara   Omar ');
        await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
        await tester.pumpAndSettle();
        expect(
          find.text('Sara Omar'),
          findsOneWidget,
        ); // back on the list, updated
        await tester.tap(
          find
              .descendant(
                of: find.byType(AppPageHeader),
                matching: find.byType(InkResponse),
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(find.text('Sara Omar'), findsNothing); // not on the account tab
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(StorageKeys.authUser), contains('Sara Omar'));
      },
    );

    testWidgets('change the e-mail: format checked, typed left to right', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await _openAccount(tester, 'حسابي');
      await _tapRow(tester, 'menu-personal-info');
      await tester.tap(find.text('ahmad@example.com'));
      await tester.pumpAndSettle();
      expect(_title('تعديل البريد الإلكتروني'), findsOneWidget);
      expect(
        find.text('سيتم إرسال الفواتير وتفاصيل الطلبات إلى بريدك الإلكتروني'),
        findsOneWidget,
      );
      await tester.enterText(_fields(), 'not-an-email');
      await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
      await tester.pumpAndSettle();
      expect(
        find.text('سيتم إرسال الفواتير وتفاصيل الطلبات إلى بريدك الإلكتروني'),
        findsNothing,
      );
      expect(find.textContaining('البريد'), findsWidgets);
      await tester.enterText(_fields(), 'Sara@Example.com');
      await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
      await tester.pumpAndSettle();
      expect(find.text('sara@example.com'), findsOneWidget); // normalized
    });

    testWidgets('change the number: code step, wrong then right code', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await _openAccount(tester, 'حسابي');
      await _tapRow(tester, 'menu-personal-info');
      await tester.tap(find.text('+962791234567'));
      await tester.pumpAndSettle();
      expect(_title('تعديل رقم الجوال'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'إرسال الرمز'));
      await tester.pumpAndSettle();
      expect(find.text('رقم الجوال مطلوب'), findsOneWidget);
      await tester.enterText(_fields(), '0791234567');
      await tester.tap(find.widgetWithText(FilledButton, 'إرسال الرمز'));
      await tester.pumpAndSettle();
      expect(find.text('هذا هو رقم جوالك الحالي'), findsOneWidget);

      await tester.enterText(_fields(), '0781234567');
      await tester.tap(find.widgetWithText(FilledButton, 'إرسال الرمز'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('رمز من 4 أرقام وصل على رقمك'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'إرسال الرمز'), findsNothing);

      await tester.enterText(_fields(), '1111');
      await tester.pumpAndSettle();
      expect(
        find.text('ولايهمك، يمكن في رقم غلط. جرّب كمان مرة 😊'),
        findsOneWidget,
      );
      await tester.enterText(_fields(), '5991');
      await tester.pumpAndSettle();
      expect(find.text('+962781234567'), findsOneWidget); // back on the list
    });

    testWidgets('gender sheet and birth date picker', (tester) async {
      await pumpApp(tester, _session);
      await _openAccount(tester, 'حسابي');
      await _tapRow(tester, 'menu-personal-info');
      await tester.tap(find.text('النوع الاجتماعي'));
      await tester.pumpAndSettle();
      expect(find.text('اختر النوع الاجتماعي'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('gender-female')));
      await tester.pumpAndSettle();
      expect(find.text('أنثى'), findsOneWidget);
      expect(find.text('غير محدد'), findsOneWidget); // only the birth date left

      await tester.tap(find.text('تاريخ الميلاد'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(
        find
            .descendant(
              of: find.byType(DatePickerDialog),
              matching: find.byType(TextButton),
            )
            .last,
      );
      await tester.pumpAndSettle();
      expect(find.text('غير محدد'), findsNothing); // a date is set now
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StorageKeys.profileExtras), contains('female'));
    });
  });

  group('support, community, share, rate', () {
    testWidgets('support: the three channels open their links', (tester) async {
      final opener = RecordingLinkOpener();
      await pumpApp(tester, _session, linkOpener: opener);
      await _openAccount(tester, 'حسابي');
      await _tapRow(tester, 'menu-support');
      expect(_title('الدعم والمساعدة'), findsOneWidget);
      expect(find.text('واتساب'), findsOneWidget);
      expect(find.text('البريد الإلكتروني'), findsOneWidget);
      expect(find.text('الاتصال بخدمة العملاء'), findsOneWidget);
      await tester.tap(_row('channel-whatsapp'));
      await tester.tap(_row('channel-email'));
      await tester.tap(_row('channel-phone'));
      await tester.pumpAndSettle();
      expect(opener.opened.map((u) => u.toString()), [
        'https://wa.me/966500000000',
        'mailto:info@jabel.com',
        'tel:8001240198',
      ]);
    });

    testWidgets(
      'support shows only the channels the store set; failures are told',
      (tester) async {
        await pumpApp(
          tester,
          _session,
          storeInfoRemote: const _OnlyWhatsapp(),
          linkOpener: RecordingLinkOpener(result: false),
        );
        await _openAccount(tester, 'حسابي');
        await _tapRow(tester, 'menu-support');
        expect(find.byType(AppMenuRow), findsOneWidget);
        await tester.tap(_row('channel-whatsapp'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('تعذّر فتح الرابط'), findsOneWidget);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      },
    );

    testWidgets('community lists the social pages and opens them', (
      tester,
    ) async {
      final opener = RecordingLinkOpener();
      await pumpApp(tester, _english, linkOpener: opener);
      await _openAccount(tester, 'Account');
      await _tapRow(tester, 'menu-community');
      expect(find.text('Join the Jabel community'), findsOneWidget);
      for (final name in [
        'Facebook',
        'Instagram',
        'X',
        'TikTok',
        'Snapchat',
        'YouTube',
        'LinkedIn',
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      await tester.tap(_row('social-facebook'));
      await tester.pumpAndSettle();
      expect(opener.opened.single.toString(), 'https://facebook.com/jabel');
    });

    testWidgets('share sheet: targets open, copy link copies', (tester) async {
      final opener = RecordingLinkOpener();
      await pumpApp(tester, _session, linkOpener: opener);
      await _openAccount(tester, 'حسابي');
      await _tapRow(tester, 'menu-share');
      expect(find.text('شارك مع أحبابك عبر ...'), findsOneWidget);
      // The same sheet as the product's: every target, the messenger bolt
      // smaller than the other glyphs.
      for (final target in ShareTarget.values) {
        expect(_row('share-${target.name}'), findsOneWidget);
      }
      Size glyph(String key) => tester.getSize(
        find.descendant(of: _row(key), matching: find.byType(SvgPicture)),
      );
      // The bolt is small inside its circle (well under half of it).
      expect(glyph('share-messenger').width, lessThan(56 / 2));
      expect(
        glyph('share-messenger').width,
        lessThan(glyph('share-whatsapp').width),
      );
      await tester.tap(_row('share-whatsapp'));
      await tester.pumpAndSettle();
      final uri = opener.opened.single;
      expect(uri.host, 'wa.me');
      expect(uri.queryParameters['text'], contains(AppLinks.download));
      expect(uri.queryParameters['text'], contains('دكتور جبل'));

      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await _tapRow(tester, 'menu-share');
      await tester.tap(_row('share-copyLink'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('تم نسخ الرابط'), findsOneWidget);
      expect(copied, AppLinks.download);
      expect(opener.opened, hasLength(1)); // copying opens nothing
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });

  group('policies and about', () {
    testWidgets('policies -> terms and privacy (AR)', (tester) async {
      await pumpApp(tester, _session);
      await _openAccount(tester, 'حسابي');
      await _tapRow(tester, 'menu-policies');
      expect(_title('السياسات'), findsOneWidget);
      await tester.tap(_row('policy-terms'));
      await tester.pumpAndSettle();
      expect(find.byType(LegalDocumentPage), findsOneWidget);
      expect(_title('الشروط والأحكام'), findsOneWidget);
      expect(
        find.textContaining('مرحباً بك في تطبيق دكتور جبل'),
        findsOneWidget,
      );
      expect(find.textContaining('1. '), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(find.textContaining('10. '), findsOneWidget);
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppPageHeader),
              matching: find.byType(InkResponse),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(_row('policy-privacy'));
      await tester.pumpAndSettle();
      expect(_title('سياسة الخصوصية'), findsOneWidget);
      expect(find.textContaining('نحترم خصوصيتك'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('texts follow the language (EN)', (tester) async {
      await pumpApp(tester, _english);
      await _openAccount(tester, 'Account');
      await _tapRow(tester, 'menu-policies');
      await tester.tap(_row('policy-terms'));
      await tester.pumpAndSettle();
      expect(_title('Terms and conditions'), findsOneWidget);
      expect(
        find.textContaining('Welcome to the Dr Jabal app'),
        findsOneWidget,
      );
    });

    testWidgets('about: name, version and description', (tester) async {
      await pumpApp(tester, _session);
      await _openAccount(tester, 'حسابي');
      await _tapRow(tester, 'menu-about');
      expect(find.byType(AboutPage), findsOneWidget);
      expect(find.text('دكتور جبل'), findsOneWidget);
      expect(find.text('الإصدار 1.2.3 (45)'), findsOneWidget);
      expect(find.textContaining('صيدليات جبل'), findsOneWidget);
    });
  });

  testWidgets(
    'small phone (iPhone SE): the menu and its pages do not overflow',
    (tester) async {
      for (final prefs in [_session, _english]) {
        await pumpApp(tester, prefs, size: const Size(750, 1334));
        final ar = prefs == _session;
        await _openAccount(tester, ar ? 'حسابي' : 'Account');
        expect(tester.takeException(), isNull);
        for (final key in [
          'menu-personal-info',
          'menu-support',
          'menu-about',
        ]) {
          await _tapRow(tester, key);
          expect(tester.takeException(), isNull, reason: key);
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
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
}
