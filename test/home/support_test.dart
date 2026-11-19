import 'package:dr_jabel/core/error/exceptions.dart';
import 'package:dr_jabel/core/error/failures.dart';
import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/utils/result.dart';
import 'package:dr_jabel/features/address/presentation/widgets/hint_tooltip.dart';
import 'package:dr_jabel/features/home/data/datasources/mock_home_remote_data_source.dart';
import 'package:dr_jabel/features/home/data/models/support_contact_model.dart';
import 'package:dr_jabel/features/home/data/repositories/home_repository_impl.dart';
import 'package:dr_jabel/features/home/domain/entities/support_contact.dart';
import 'package:dr_jabel/features/home/domain/usecases/contact_support.dart';
import 'package:dr_jabel/features/home/presentation/widgets/ask_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _session = {
  StorageKeys.onboardingSeen: true,
  StorageKeys.authToken: 'mock-token-1',
  StorageKeys.authUser:
      '{"id":"1","name":"Ahmad Ali","phone":"+962791234567","email":null}',
};
const _english = {..._session, StorageKeys.languageCode: 'en'};

/// A store that has not set a WhatsApp number.
class _NoNumber extends MockHomeRemoteDataSource {
  const _NoNumber() : super(latency: Duration.zero);

  @override
  Future<SupportContact> fetchSupportContact() =>
      Future.error(const NotFoundException());
}

Future<void> _tapCard(WidgetTester tester, String label) async {
  if (find.byType(HintTooltip).evaluate().isNotEmpty) {
    await tester.tap(find.byType(HintTooltip));
    await tester.pumpAndSettle();
  }
  await tester.scrollUntilVisible(
    find.text(label),
    100,
    scrollable: find
        .descendant(
          of: find.byType(RefreshIndicator),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.tap(find.text(label));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('SupportContact', () {
    test(
      'reads the number from a wa.me link, a phone= link or plain digits',
      () {
        SupportContact? read(Object? value) =>
            SupportContactModel.tryFromSettings({'whatsapp': value});
        expect(
          read('https://wa.me/966500000000')?.whatsappNumber,
          '966500000000',
        );
        expect(
          read('https://wa.me/+962791234567?text=hi')?.whatsappNumber,
          '962791234567',
        );
        expect(
          read(
            'https://api.whatsapp.com/send?phone=962791234567',
          )?.whatsappNumber,
          '962791234567',
        );
        expect(read('+962 79 123 4567')?.whatsappNumber, '962791234567');
        expect(read('962791234567')?.whatsappNumber, '962791234567');
        // nothing usable
        expect(read(null), isNull);
        expect(read(''), isNull);
        expect(read('https://wa.me/'), isNull);
        expect(read('not a number'), isNull);
        expect(read('123'), isNull); // too short
        expect(read('1234567890123456'), isNull); // too long
        expect(SupportContactModel.tryFromSettings({}), isNull);
      },
    );

    test('the chat link carries the message, Arabic included', () {
      const contact = SupportContact(whatsappNumber: '962791234567');
      final uri = contact.whatsappChat('مرحباً، أريد استشارة صيدلي');
      expect(uri.scheme, 'https');
      expect(uri.host, 'wa.me');
      expect(uri.path, '/962791234567');
      expect(uri.queryParameters['text'], 'مرحباً، أريد استشارة صيدلي');
      expect(
        uri.toString(),
        startsWith('https://wa.me/962791234567?text=%D9%85'),
      );
      expect(contact.whatsappChat('').hasQuery, isFalse);
    });
  });

  group('ContactSupport', () {
    const repository = HomeRepositoryImpl(
      MockHomeRemoteDataSource(latency: Duration.zero),
    );

    test('opens the chat with the support number', () async {
      final opener = RecordingLinkOpener();
      final result = await ContactSupport(repository, opener)('hi');
      expect(result, isA<Success<void>>());
      expect(
        opener.opened.single.toString(),
        'https://wa.me/966500000000?text=hi',
      );
    });

    test('WhatsApp could not open -> failure', () async {
      final opener = RecordingLinkOpener(result: false);
      final result = await ContactSupport(repository, opener)('hi');
      expect((result as Err<void>).failure, isA<UnknownFailure>());
      expect(opener.opened, hasLength(1));
    });

    test('no number set -> failure, nothing is opened', () async {
      final opener = RecordingLinkOpener();
      final result = await ContactSupport(
        const HomeRepositoryImpl(_NoNumber()),
        opener,
      )('hi');
      expect((result as Err<void>).failure, isA<NotFoundFailure>());
      expect(opener.opened, isEmpty);
    });
  });

  group('home cards', () {
    testWidgets('ask the pharmacist -> WhatsApp with its message (AR)', (
      tester,
    ) async {
      final opener = RecordingLinkOpener();
      await pumpApp(tester, _session, linkOpener: opener);
      await _tapCard(tester, 'اسأل الصيدلي');
      final uri = opener.opened.single;
      expect(uri.host, 'wa.me');
      expect(uri.path, '/966500000000');
      expect(uri.queryParameters['text'], 'مرحباً، أريد استشارة صيدلي');
      expect(
        find.text('تعذّر فتح واتساب. تأكد من تثبيته وحاول مرة أخرى'),
        findsNothing,
      );
    });

    testWidgets('ask a beauty specialist has its own message', (tester) async {
      final opener = RecordingLinkOpener();
      await pumpApp(tester, _session, linkOpener: opener);
      await _tapCard(tester, 'اسأل اخصائي التجميل');
      expect(opener.opened.single.path, '/966500000000');
      expect(
        opener.opened.single.queryParameters['text'],
        'مرحباً، أريد استشارة أخصائي تجميل',
      );
    });

    testWidgets('English messages', (tester) async {
      final opener = RecordingLinkOpener();
      await pumpApp(tester, _english, linkOpener: opener);
      await _tapCard(tester, 'Ask the pharmacist');
      await _tapCard(tester, 'Ask a beauty specialist');
      expect(opener.opened.map((u) => u.queryParameters['text']), [
        'Hello, I would like to ask a pharmacist',
        'Hello, I would like to ask a beauty specialist',
      ]);
    });

    testWidgets('WhatsApp not installed -> a message, no crash', (
      tester,
    ) async {
      final opener = RecordingLinkOpener(result: false);
      await pumpApp(tester, _session, linkOpener: opener);
      await _tapCard(tester, 'اسأل الصيدلي');
      expect(opener.opened, hasLength(1));
      expect(
        find.text('تعذّر فتح واتساب. تأكد من تثبيته وحاول مرة أخرى'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('no support number -> the same message', (tester) async {
      final opener = RecordingLinkOpener();
      await pumpApp(
        tester,
        _session,
        homeRemote: const _NoNumber(),
        linkOpener: opener,
      );
      await _tapCard(tester, 'اسأل الصيدلي');
      expect(opener.opened, isEmpty);
      expect(
        find.text('تعذّر فتح واتساب. تأكد من تثبيته وحاول مرة أخرى'),
        findsOneWidget,
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('the cards are real buttons', (tester) async {
      await pumpApp(tester, _session);
      expect(find.byType(AskCard), findsNWidgets(2));
      for (final card in tester.widgetList<AskCard>(find.byType(AskCard))) {
        expect(card.onTap, isNotNull);
      }
    });
  });
}
