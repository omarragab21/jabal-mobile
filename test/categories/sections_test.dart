import 'package:dr_jabel/core/error/exceptions.dart';
import 'package:dr_jabel/core/error/failures.dart';
import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/utils/result.dart';
import 'package:dr_jabel/core/widgets/app_page_header.dart';
import 'package:dr_jabel/features/address/presentation/widgets/hint_tooltip.dart';
import 'package:dr_jabel/features/categories/domain/usecases/get_sections.dart';
import 'package:dr_jabel/features/categories/presentation/cubit/sections_cubit.dart';
import 'package:dr_jabel/features/categories/presentation/pages/categories_page.dart';
import 'package:dr_jabel/features/categories/presentation/widgets/section_tile.dart';
import 'package:dr_jabel/features/home/data/datasources/mock_home_remote_data_source.dart';
import 'package:dr_jabel/features/home/data/models/product_category_model.dart';
import 'package:dr_jabel/features/home/data/repositories/home_repository_impl.dart';
import 'package:dr_jabel/features/home/domain/entities/product_category.dart';
import 'package:dr_jabel/features/home/presentation/pages/category_page.dart';
import 'package:dr_jabel/features/home/presentation/widgets/category_chips.dart';
import 'package:dr_jabel/features/home/presentation/widgets/home_search_field.dart';
import 'package:dr_jabel/features/search/presentation/pages/search_page.dart';
import 'package:dr_jabel/features/home/presentation/widgets/product_card.dart';
import 'package:dr_jabel/features/main/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _session = {
  StorageKeys.onboardingSeen: true,
  StorageKeys.authToken: 'mock-token-1',
  StorageKeys.authUser:
      '{"id":"1","name":"Ahmad Ali","phone":"+962791234567","email":null}',
};
const _english = {..._session, StorageKeys.languageCode: 'en'};

const _fast = MockHomeRemoteDataSource(latency: Duration.zero);
const _repository = HomeRepositoryImpl(_fast);

/// Categories fail until [healthy] is switched on.
class _FlakyCategories extends MockHomeRemoteDataSource {
  _FlakyCategories() : super(latency: Duration.zero);
  bool healthy = false;

  @override
  Future<List<ProductCategoryModel>> fetchCategories(String languageCode) =>
      healthy
      ? super.fetchCategories(languageCode)
      : Future.error(const NetworkException());
}

/// Opens the sections tab (the hint bubble is dismissed first: it hangs
/// over the top of the home page).
Future<void> _openSectionsTab(WidgetTester tester, String tabLabel) async {
  if (find.byType(HintTooltip).evaluate().isNotEmpty) {
    await tester.tap(find.byType(HintTooltip));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text(tabLabel).last);
  await tester.pumpAndSettle();
}

Finder _tile(int id) => find.byKey(ValueKey('section-$id'));

void main() {
  group('sections logic', () {
    test('GetSections: roots only, in the design order', () async {
      final result = await const GetSections(_repository)('ar');
      final sections = (result as Success<List<ProductCategory>>).data;
      expect(sections.map((s) => s.id), [64, 69, 63, 12, 70, 66, 71, 72]);
      expect(sections.every((s) => s.isRoot), isTrue);
      expect(sections.first.name, 'الفيتامينات والمكملات');
      expect(sections.first.imageUrl, 'assets/images/sections/vitamins.jpg');
      expect(sections.every((s) => s.hasSubCategories), isTrue);

      final en =
          (await const GetSections(_repository)('en')
                  as Success<List<ProductCategory>>)
              .data;
      expect(en[1].name, 'Medicines');
    });

    test('GetSections passes failures through', () async {
      final flaky = _FlakyCategories();
      final result = await GetSections(HomeRepositoryImpl(flaky))('ar');
      expect(
        (result as Err<List<ProductCategory>>).failure,
        isA<NetworkFailure>(),
      );
    });

    test(
      'SectionsCubit: loading, ready, failed, reload in another language',
      () async {
        final flaky = _FlakyCategories();
        final cubit = SectionsCubit(GetSections(HomeRepositoryImpl(flaky)));
        expect(cubit.state.status, SectionsStatus.loading);
        await cubit.load('ar');
        expect(cubit.state.status, SectionsStatus.failed);
        expect(cubit.state.failure, isA<NetworkFailure>());
        flaky.healthy = true;
        await cubit.load('en');
        expect(cubit.state.status, SectionsStatus.ready);
        expect(cubit.state.sections.first.name, 'Vitamins & supplements');
        await cubit.close();
      },
    );
  });

  group('SectionTile', () {
    Widget host(Widget child, TextDirection direction) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Center(child: SizedBox(width: 160, child: child)),
          ),
        ),
      ),
    );

    testWidgets('name on top at the start edge, over a 30% veil; 160 x 110', (
      tester,
    ) async {
      var taps = 0;
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          host(
            SectionTile(
              name: 'الأدوية العلاجية',
              imageUrl: 'assets/images/sections/medicines.jpg',
              onTap: () => taps++,
            ),
            direction,
          ),
        );
        final tile = tester.getRect(find.byType(SectionTile));
        final text = tester.getRect(find.text('الأدوية العلاجية'));
        expect(tile.height / tile.width, closeTo(110 / 160, 0.001));
        expect(text.top - tile.top, closeTo(12.h, 1));
        if (direction == TextDirection.rtl) {
          expect(tile.right - text.right, closeTo(13.w, 1));
        } else {
          expect(text.left - tile.left, closeTo(13.w, 1));
        }
        final veil = tester.widget<ColoredBox>(
          find
              .descendant(
                of: find.byType(SectionTile),
                matching: find.byType(ColoredBox),
              )
              .last,
        );
        expect(veil.color.a, closeTo(0.3, 0.01));
        expect(find.byType(Image), findsOneWidget);
      }
      await tester.tap(find.byType(SectionTile));
      expect(taps, 1);
    });

    testWidgets('a missing picture shows a plain placeholder, no crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SectionTile(name: 'x', imageUrl: null), TextDirection.rtl),
      );
      expect(find.byType(Image), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('sections tab', () {
    testWidgets('(AR) header, search, eight tiles in the design layout', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      await _openSectionsTab(tester, 'الأقسام');

      expect(find.byType(SectionsPage), findsOneWidget);
      final header = find.byType(AppPageHeader);
      expect(tester.getSize(header).height, closeTo(58.h, 0.5));
      expect(
        find.descendant(of: header, matching: find.text('الأقسام')),
        findsOneWidget,
      );
      // the arrow at the right edge
      expect(
        tester
            .getCenter(
              find.descendant(of: header, matching: find.byType(InkResponse)),
            )
            .dx,
        greaterThan(width / 2),
      );
      // search field, 40pt, right under the header
      expect(find.byType(HomeSearchField), findsOneWidget);
      expect(
        tester.getSize(find.byType(HomeSearchField)).height,
        closeTo(40.h, 0.5),
      );
      expect(find.text('ابحث عن منتج ...'), findsOneWidget);

      // eight tiles; first (vitamins) top right, second left of it
      expect(find.byType(SectionTile), findsNWidgets(8));
      final first = tester.getRect(_tile(64));
      final second = tester.getRect(_tile(69));
      expect(first.right, closeTo(width - 16.w, 0.5));
      expect(second.left, closeTo(16.w, 0.5));
      expect(first.left - second.right, closeTo(23.w, 0.5));
      expect(first.top, second.top);
      expect(first.width, closeTo(160.w, 1));
      expect(first.height, closeTo(110.h, 1));
      final third = tester.getRect(_tile(63));
      expect(third.top - first.bottom, closeTo(16.h, 0.5));
      expect(third.right, first.right);
      // names
      for (final name in [
        'الفيتامينات والمكملات',
        'الأدوية العلاجية',
        'العناية بالشعر',
        'العناية بالبشرة',
        'الأجهزة والمستلزمات',
        'الأم والطفل',
        'رعاية كبار السن',
        'الإسعافات الأولية',
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      // page background
      expect(
        tester
            .widget<ColoredBox>(
              find
                  .descendant(
                    of: find.byType(SectionsPage),
                    matching: find.byType(ColoredBox),
                  )
                  .first,
            )
            .color,
        const Color(0xFFF9FAFB),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('(EN) mirrored', (tester) async {
      await pumpApp(tester, _english);
      final width =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      await _openSectionsTab(tester, 'Categories');
      final header = find.byType(AppPageHeader);
      expect(
        tester
            .getCenter(
              find.descendant(of: header, matching: find.byType(InkResponse)),
            )
            .dx,
        lessThan(width / 2),
      );
      expect(find.text('Search for a product ...'), findsOneWidget);
      final first = tester.getRect(_tile(64));
      final second = tester.getRect(_tile(69));
      expect(first.left, closeTo(16.w, 0.5));
      expect(second.right, closeTo(width - 16.w, 0.5));
      expect(find.text('Vitamins & supplements'), findsOneWidget);
      expect(find.text('First aid'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a section opens its page, with its sub-sections', (
      tester,
    ) async {
      await pumpApp(tester, _session);
      await _openSectionsTab(tester, 'الأقسام');
      await tester.tap(_tile(69));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryPage), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppPageHeader),
          matching: find.text('الأدوية العلاجية'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(CategoryChips),
          matching: find.text('مسكنات وخافضات حرارة'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('product-201')), findsOneWidget);

      // filter to "cold & cough": only its three products... then back
      final cold = find.descendant(
        of: find.byType(CategoryChips),
        matching: find.text('البرد والسعال'),
      );
      await tester.scrollUntilVisible(
        cold,
        80,
        scrollable: find
            .descendant(
              of: find.byType(CategoryChips),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.ensureVisible(cold);
      await tester.pumpAndSettle();
      await tester.tap(cold);
      await tester.pumpAndSettle();
      expect(find.byType(ProductCard), findsNWidgets(3));
      expect(find.byKey(const ValueKey('product-201')), findsNothing);
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppPageHeader),
              matching: find.byType(InkResponse),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.byType(CategoryPage), findsNothing);
      expect(find.byType(SectionsPage), findsOneWidget);
    });

    testWidgets('the header arrow goes back to the home tab', (tester) async {
      await pumpApp(tester, _session);
      await _openSectionsTab(tester, 'الأقسام');
      expect(find.byType(SectionTile), findsNWidgets(8));
      await tester.tap(
        find.descendant(
          of: find.byType(AppPageHeader),
          matching: find.byType(InkResponse),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavBar), findsOneWidget);
      expect(find.byType(HomeSearchField), findsWidgets);
      expect(find.text('أين تريد التوصيل؟'), findsOneWidget); // home header
    });

    testWidgets('the search field opens the search screen', (tester) async {
      await pumpApp(tester, _session);
      await _openSectionsTab(tester, 'الأقسام');
      expect(find.byType(SectionTile), findsNWidgets(8));

      await tester.tap(find.byType(HomeSearchField));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsOneWidget);
      expect(
        find.byType(SectionTile),
        findsNothing,
        reason: 'a screen of its own',
      );
    });

    testWidgets('load error shows retry that recovers', (tester) async {
      final remote = _FlakyCategories();
      await pumpApp(tester, _session, homeRemote: remote);
      await _openSectionsTab(tester, 'الأقسام');
      expect(find.text('تعذّر تحميل الأقسام'), findsOneWidget);
      remote.healthy = true;
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();
      expect(find.byType(SectionTile), findsNWidgets(8));
    });

    testWidgets('small phone (iPhone SE): no overflow in either language', (
      tester,
    ) async {
      for (final prefs in [_session, _english]) {
        await pumpApp(tester, prefs, size: const Size(750, 1334));
        await _openSectionsTab(
          tester,
          prefs == _session ? 'الأقسام' : 'Categories',
        );
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byType(SectionTile).first,
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    });
  });
}
