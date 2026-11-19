import 'package:dr_jabel/core/error/exceptions.dart';
import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/widgets/app_page_header.dart';
import 'package:dr_jabel/features/address/presentation/widgets/hint_tooltip.dart';
import 'package:dr_jabel/features/home/data/datasources/mock_home_remote_data_source.dart';
import 'package:dr_jabel/features/home/presentation/pages/category_page.dart';
import 'package:dr_jabel/features/home/data/models/product_category_model.dart';
import 'package:dr_jabel/features/home/presentation/widgets/ask_cards.dart';
import 'package:dr_jabel/features/home/presentation/widgets/banner_carousel.dart';
import 'package:dr_jabel/features/home/presentation/widgets/category_grid.dart';
import 'package:dr_jabel/features/home/presentation/widgets/home_search_field.dart';
import 'package:dr_jabel/features/search/presentation/pages/search_page.dart';
import 'package:dr_jabel/features/home/presentation/widgets/news_ticker.dart';
import 'package:dr_jabel/features/home/presentation/widgets/product_card.dart';
import 'package:dr_jabel/features/home/presentation/widgets/product_section.dart';
import 'package:dr_jabel/core/widgets/count_badge.dart';
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

/// Categories fail until [healthy] is switched on.
class _FlakyRemote extends MockHomeRemoteDataSource {
  _FlakyRemote() : super(latency: Duration.zero);
  bool healthy = false;

  @override
  Future<List<ProductCategoryModel>> fetchCategories(String languageCode) =>
      healthy
      ? super.fetchCategories(languageCode)
      : Future.error(const NetworkException());
}

Finder _card(int id) => find.byKey(ValueKey('product-$id'));

/// The `Semantics` widget that carries exactly [label].
Finder _labelled(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find
        .descendant(
          of: find.byType(RefreshIndicator),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Arabic home: every block, laid out right-to-left', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;

    // header: no address chosen yet, the question starts at the right edge
    final address = find.text('أين تريد التوصيل؟');
    expect(address, findsOneWidget);
    expect(tester.getTopRight(address).dx, closeTo(width - 16.w, 1));

    // search: magnifier on the right, hint in Arabic, 40pt high
    final field = find.byType(HomeSearchField);
    expect(tester.getSize(field).height, closeTo(40.h, 0.5));
    expect(find.text('ابحث عن منتج ...'), findsOneWidget);
    expect(
      tester.getCenter(find.byType(TextField)).dx,
      lessThan(tester.getCenter(field).dx + 20),
    );

    // news bar: full width, the active items only
    final ticker = tester.widget<NewsTicker>(find.byType(NewsTicker));
    expect(ticker.items, hasLength(5));
    expect(ticker.items.first, startsWith('صيدليات الجبل'));
    expect(tester.getSize(find.byType(NewsTicker)).width, width);

    expect(find.byType(BannerCarousel), findsOneWidget);

    // the pharmacist card is first: on the right in Arabic
    final cards = find.byType(AskCard);
    expect(cards, findsNWidgets(2));
    expect(
      tester.getCenter(find.text('اسأل الصيدلي')).dx,
      greaterThan(tester.getCenter(find.text('اسأل اخصائي التجميل')).dx),
    );

    // categories: "all" first (rightmost), four per row
    final tiles = find.byType(CategoryTile);
    expect(tiles, findsNWidgets(9));
    expect(
      find.descendant(of: tiles.first, matching: find.text('كل الفئات')),
      findsOneWidget,
    );
    expect(
      tester.getCenter(tiles.at(0)).dx,
      greaterThan(tester.getCenter(tiles.at(1)).dx),
    );
    expect(
      tester.getTopLeft(tiles.at(0)).dy,
      tester.getTopLeft(tiles.at(3)).dy,
    );
    expect(
      tester.getTopLeft(tiles.at(4)).dy,
      greaterThan(tester.getTopLeft(tiles.at(0)).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic product section: title right, arrow left, card parts', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    await _scrollTo(tester, _card(104));

    final header = find.widgetWithText(SectionHeader, 'الفيتامينات والمكملات');
    expect(header, findsOneWidget);
    final title = find.descendant(
      of: header,
      matching: find.text('الفيتامينات والمكملات'),
    );
    final arrow = find.descendant(
      of: header,
      matching: find.byType(InkResponse),
    );
    expect(tester.getCenter(title).dx, greaterThan(tester.getCenter(arrow).dx));

    // first card of the row is the rightmost one
    expect(
      tester.getCenter(_card(104)).dx,
      greaterThan(tester.getCenter(_card(105)).dx),
    );
    expect(tester.getSize(_card(105)).width, closeTo(160.w, 0.5));

    // discounted card: both prices, the paid one to the right of the old one
    final card = _card(105);
    Finder inCard(String text) =>
        find.descendant(of: card, matching: find.text(text));
    expect(inCard('فيتامين د3 5000 وحدة'), findsOneWidget);
    expect(inCard('60 كبسولة'), findsOneWidget);
    expect(inCard('8.25 د.أ'), findsOneWidget);
    final old = tester.widget<Text>(inCard('9.75 د.أ'));
    expect(old.style?.decoration, TextDecoration.lineThrough);
    // the paid price leads: it starts at the card's right edge
    expect(
      tester.getTopRight(inCard('8.25 د.أ')).dx,
      closeTo(tester.getTopRight(card).dx, 0.5),
    );
    // no discount -> no crossed-out price
    expect(
      find.descendant(of: _card(104), matching: find.textContaining('د.أ')),
      findsOneWidget,
    );

    // heart on the left corner of the picture, button under the right edge
    final heart = find.descendant(
      of: card,
      matching: _labelled('إضافة إلى المفضلة'),
    );
    expect(tester.getCenter(heart).dx, lessThan(tester.getCenter(card).dx));
    final button = find.descendant(
      of: card,
      matching: find.widgetWithText(FilledButton, 'أضف للسلة'),
    );
    expect(
      tester.getTopRight(button).dx,
      closeTo(tester.getTopRight(card).dx, 0.5),
    );
    expect(tester.getSize(button).height, closeTo(32.h, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('English home mirrors to left-to-right', (tester) async {
    await pumpApp(tester, _english);
    expect(directionOf(tester), TextDirection.ltr);

    final address = find.text('Where do you want it delivered?');
    expect(tester.getTopLeft(address).dx, closeTo(16.w, 1));
    expect(find.text('Search for a product ...'), findsOneWidget);
    expect(
      tester.getCenter(find.text('Ask the pharmacist')).dx,
      lessThan(tester.getCenter(find.text('Ask a beauty specialist')).dx),
    );
    final tiles = find.byType(CategoryTile);
    expect(
      find.descendant(of: tiles.first, matching: find.text('All categories')),
      findsOneWidget,
    );
    expect(
      tester.getCenter(tiles.at(0)).dx,
      lessThan(tester.getCenter(tiles.at(1)).dx),
    );

    await _scrollTo(tester, _card(105));
    final header = find.widgetWithText(SectionHeader, 'Vitamins & supplements');
    final arrow = find.descendant(
      of: header,
      matching: find.byType(InkResponse),
    );
    expect(
      tester
          .getCenter(
            find.descendant(
              of: header,
              matching: find.text('Vitamins & supplements'),
            ),
          )
          .dx,
      lessThan(tester.getCenter(arrow).dx),
    );
    expect(
      tester.getCenter(_card(104)).dx,
      lessThan(tester.getCenter(_card(105)).dx),
    );

    final card = _card(105);
    Finder inCard(String text) =>
        find.descendant(of: card, matching: find.text(text));
    expect(inCard('Vitamin D3 5000 IU'), findsOneWidget);
    expect(inCard('60 capsules'), findsOneWidget);
    expect(
      tester.getTopLeft(inCard('8.25 JOD')).dx,
      closeTo(tester.getTopLeft(card).dx, 0.5),
    );
    final heart = find.descendant(
      of: card,
      matching: _labelled('Add to favourites'),
    );
    expect(tester.getCenter(heart).dx, greaterThan(tester.getCenter(card).dx));
    final button = find.descendant(
      of: card,
      matching: find.widgetWithText(FilledButton, 'Add to cart'),
    );
    expect(
      tester.getTopLeft(button).dx,
      closeTo(tester.getTopLeft(card).dx, 0.5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('add to cart: badge counts up and a message shows', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    expect(find.byType(CountBadge), findsNothing);
    await _scrollTo(tester, _card(104));
    final add = find.descendant(
      of: _card(105),
      matching: find.widgetWithText(FilledButton, 'أضف للسلة'),
    );
    await tester.tap(add);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('تمت إضافة «فيتامين د3 5000 وحدة» إلى السلة'),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(CountBadge), matching: find.text('1')),
      findsOneWidget,
    );
    await tester.tap(add);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.descendant(of: find.byType(CountBadge), matching: find.text('2')),
      findsOneWidget,
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });

  testWidgets('heart toggles the favourite', (tester) async {
    await pumpApp(tester, _session);
    // the address hint hangs over the top of the list: dismiss it
    await tester.tap(find.byType(HintTooltip));
    await tester.pumpAndSettle();
    await _scrollTo(tester, _card(104));
    final card = _card(104);
    await tester.tap(
      find.descendant(of: card, matching: _labelled('إضافة إلى المفضلة')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: card, matching: find.byIcon(Icons.favorite)),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(of: card, matching: _labelled('إزالة من المفضلة')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: card, matching: find.byIcon(Icons.favorite)),
      findsNothing,
    );
  });

  testWidgets('the search field opens the search screen', (tester) async {
    await pumpApp(tester, _session);
    // It only opens the screen: nothing is typed on the home page itself.
    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    await tester.tap(find.byType(HomeSearchField));
    await tester.pumpAndSettle();
    expect(find.byType(SearchPage), findsOneWidget);
    expect(find.text('ابحث عن منتج ...'), findsOneWidget);

    // Back to the home page, which is untouched.
    await tester.tap(find.byType(InkResponse).first);
    await tester.pumpAndSettle();
    expect(find.byType(SearchPage), findsNothing);
    expect(find.byType(NewsTicker), findsOneWidget);
  });

  testWidgets(
    '"all categories" opens the categories tab, a section arrow its category page',
    (tester) async {
      await pumpApp(tester, _session);
      expect(find.text('الأقسام'), findsOneWidget); // tab label only
      await tester.tap(find.text('كل الفئات'));
      await tester.pumpAndSettle();
      expect(find.text('الأقسام'), findsNWidgets(2)); // + page title

      await tester.tap(find.text('الرئيسية'));
      await tester.pumpAndSettle();
      await _scrollTo(tester, _card(104));
      final arrow = find.descendant(
        of: find.widgetWithText(SectionHeader, 'الفيتامينات والمكملات'),
        matching: find.byType(InkResponse),
      );
      await tester.ensureVisible(arrow);
      await tester.pumpAndSettle();
      await tester.tap(arrow);
      await tester.pumpAndSettle();
      expect(find.byType(CategoryPage), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppPageHeader),
          matching: find.text('الفيتامينات والمكملات'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('load error shows a retry that recovers', (tester) async {
    final remote = _FlakyRemote();
    await pumpApp(tester, _session, homeRemote: remote);
    expect(find.text('تعذّر تحميل الصفحة الرئيسية'), findsOneWidget);
    expect(find.byType(NewsTicker), findsNothing);
    // the header stays usable
    expect(find.byType(HomeSearchField), findsOneWidget);

    remote.healthy = true;
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(find.text('تعذّر تحميل الصفحة الرئيسية'), findsNothing);
    expect(find.byType(CategoryTile), findsNWidgets(9));
  });

  testWidgets('small phone (iPhone SE): no overflow in either language', (
    tester,
  ) async {
    for (final prefs in [_session, _english]) {
      await pumpApp(tester, prefs, size: const Size(750, 1334));
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, -900));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // The search lives on its own screen now.
      await tester.tap(find.byType(HomeSearchField));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(SearchPage),
          matching: find.byType(TextField),
        ),
        prefs == _session ? 'شامبو' : 'shampoo',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.byType(ProductCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });

  group('NewsTicker', () {
    Future<double> travel(WidgetTester tester, TextDirection direction) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => Directionality(
            textDirection: direction,
            child: const Align(
              alignment: Alignment.topCenter,
              child: NewsTicker(items: ['first item', 'second item']),
            ),
          ),
        ),
      );
      await tester.pump();
      final before = tester.getCenter(find.text('first item').first).dx;
      await tester.pump(const Duration(seconds: 1));
      final after = tester.getCenter(find.text('first item').first).dx;
      await tester.pumpWidget(const SizedBox());
      return after - before;
    }

    testWidgets('moves right in Arabic and left in English, 40pt/s', (
      tester,
    ) async {
      expect(await travel(tester, TextDirection.rtl), closeTo(40, 1));
      expect(await travel(tester, TextDirection.ltr), closeTo(-40, 1));
    });

    testWidgets('stays still when animations are off; hidden when empty', (
      tester,
    ) async {
      Widget host(Widget child) => ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => Directionality(
          textDirection: TextDirection.rtl,
          child: Align(alignment: Alignment.topCenter, child: child),
        ),
      );
      await tester.pumpWidget(
        host(const NewsTicker(items: ['خبر'], animate: false)),
      );
      await tester.pumpAndSettle(); // would time out if it were moving
      expect(find.text('خبر'), findsWidgets);

      await tester.pumpWidget(host(const NewsTicker(items: [])));
      expect(tester.getSize(find.byType(NewsTicker)).height, 0);
    });
  });
}
