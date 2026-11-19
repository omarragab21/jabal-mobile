import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/widgets/app_page_header.dart';
import 'package:dr_jabel/core/widgets/count_badge.dart';
import 'package:dr_jabel/features/address/presentation/widgets/hint_tooltip.dart';
import 'package:dr_jabel/features/home/data/datasources/mock_home_remote_data_source.dart';
import 'package:dr_jabel/features/home/data/models/product_model.dart';
import 'package:dr_jabel/features/home/presentation/pages/category_page.dart';
import 'package:dr_jabel/features/home/presentation/widgets/category_chips.dart';
import 'package:dr_jabel/features/home/presentation/widgets/category_grid.dart';
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

const _vitaminsAr = 'الفيتامينات والمكملات';
const _vitaminsEn = 'Vitamins & supplements';

/// A catalogue without products: every section is empty.
class _NoProducts extends MockHomeRemoteDataSource {
  const _NoProducts() : super(latency: Duration.zero);

  @override
  Future<List<ProductModel>> fetchProducts(
    String languageCode, {
    String? search,
  }) async => const [];
}

/// Opens a section from the home grid.
Future<void> _openFromHome(WidgetTester tester, String label) async {
  // the address hint hangs over the top of the list: dismiss it
  if (find.byType(HintTooltip).evaluate().isNotEmpty) {
    await tester.tap(find.byType(HintTooltip));
    await tester.pumpAndSettle();
  }
  final tile = find.widgetWithText(CategoryTile, label);
  await tester.scrollUntilVisible(
    tile,
    200,
    scrollable: find
        .descendant(
          of: find.byType(RefreshIndicator),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

Finder _product(int id) => find.byKey(ValueKey('product-$id'));

/// The page title in the header (the same text can also be a card's
/// category line or a chip).
Finder _title(String text) =>
    find.descendant(of: find.byType(AppPageHeader), matching: find.text(text));

Finder _chip(String label) =>
    find.descendant(of: find.byType(CategoryChips), matching: find.text(label));

/// Taps a chip, scrolling the chip row first when it is off screen (the row
/// only builds the chips near the screen).
Future<void> _tapChip(WidgetTester tester, String label) async {
  final chip = _chip(label);
  await tester.scrollUntilVisible(
    chip,
    80,
    scrollable: find
        .descendant(
          of: find.byType(CategoryChips),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

Color? _chipColor(WidgetTester tester, String label) => tester
    .widget<Material>(
      find.ancestor(of: _chip(label), matching: find.byType(Material)).first,
    )
    .color;

void main() {
  testWidgets('section page (AR): header, chips, two-column grid', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    await _openFromHome(tester, _vitaminsAr);
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;

    expect(find.byType(CategoryPage), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsNothing); // full screen page
    expect(_title(_vitaminsAr), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
      const Color(0xFFF9FAFB),
    );

    // back arrow on the right, cart on the left, title centred
    final header = find.byType(AppPageHeader);
    expect(tester.getSize(header).height, closeTo(58.h, 0.5));
    expect(tester.getCenter(_title(_vitaminsAr)).dx, closeTo(width / 2, 1));
    final buttons = find.descendant(
      of: header,
      matching: find.byType(InkResponse),
    );
    expect(buttons, findsNWidgets(2)); // back + cart
    expect(tester.getCenter(buttons.first).dx, greaterThan(width / 2));
    expect(tester.getCenter(buttons.last).dx, lessThan(width / 2));

    // chips: 16pt under the header; "all" first, rightmost, green
    final chips = find.byType(CategoryChips);
    expect(tester.getSize(chips).height, closeTo(32.h, 0.5));
    expect(
      tester.getTopLeft(chips).dy - tester.getBottomLeft(header).dy,
      closeTo(16.h, 0.5),
    );
    for (final label in ['الكل', 'أوميغا 3', 'فيتامين سي']) {
      expect(_chip(label), findsOneWidget, reason: label);
    }
    expect(
      tester.getCenter(_chip('الكل')).dx,
      greaterThan(tester.getCenter(_chip('أوميغا 3')).dx),
    );
    expect(tester.widget<Text>(_chip('الكل')).style?.color, Colors.white);
    expect(_chipColor(tester, 'الكل'), const Color(0xFF267B00));
    expect(_chipColor(tester, 'أوميغا 3'), Colors.white);

    // grid: 16pt under the chips, 2 per row, 24pt between the columns
    expect(
      tester.getTopLeft(_product(104)).dy - tester.getBottomLeft(chips).dy,
      closeTo(16.h, 0.5),
    );
    expect(
      tester.getCenter(_product(104)).dx,
      greaterThan(tester.getCenter(_product(105)).dx),
    );
    expect(
      tester.getTopLeft(_product(104)).dy,
      tester.getTopLeft(_product(105)).dy,
    );
    expect(
      tester.getTopLeft(_product(106)).dy,
      greaterThan(tester.getTopLeft(_product(104)).dy),
    );
    expect(tester.getSize(_product(104)).width, closeTo(159.5.w, 1));
    expect(
      tester.getTopLeft(_product(104)).dx -
          tester.getTopRight(_product(105)).dx,
      closeTo(24.w, 0.5),
    );
    expect(tester.getTopRight(_product(104)).dx, closeTo(width - 16.w, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a chip filters the grid in place; "all" brings everything back',
    (tester) async {
      await pumpApp(tester, _session);
      await _openFromHome(tester, _vitaminsAr);
      expect(find.byType(ProductCard), findsAtLeastNWidgets(4));

      // vitamin C holds only product 104
      await tester.tap(_chip('فيتامين سي'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryPage), findsOneWidget); // same page, no push
      expect(_title(_vitaminsAr), findsOneWidget);
      expect(find.byType(ProductCard), findsOneWidget);
      expect(_product(104), findsOneWidget);
      expect(_chipColor(tester, 'فيتامين سي'), const Color(0xFF267B00));
      expect(_chipColor(tester, 'الكل'), Colors.white);
      expect(
        tester.widget<Text>(_chip('فيتامين سي')).style?.color,
        Colors.white,
      );
      expect(
        tester.widget<Text>(_chip('الكل')).style?.color,
        isNot(Colors.white),
      );

      // switch straight to another one
      await tester.tap(_chip('أوميغا 3'));
      await tester.pumpAndSettle();
      expect(find.byType(ProductCard), findsOneWidget);
      expect(_product(106), findsOneWidget);
      expect(_chipColor(tester, 'فيتامين سي'), Colors.white);

      // all again
      await tester.tap(_chip('الكل'));
      await tester.pumpAndSettle();
      expect(find.byType(ProductCard), findsAtLeastNWidgets(4));
      expect(_chipColor(tester, 'الكل'), const Color(0xFF267B00));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a sub-section with several products shows exactly those', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    await _openFromHome(tester, _vitaminsAr);
    // 105 and 120 are both "vitamins & immunity"
    await _tapChip(tester, 'فيتامينات ومناعة');
    expect(find.byType(ProductCard), findsNWidgets(2));
    expect(_product(105), findsOneWidget);
    expect(_product(120), findsOneWidget);
  });

  testWidgets('a filter with no products says so', (tester) async {
    await pumpApp(tester, _session, homeRemote: const _NoProducts());
    await _openFromHome(tester, _vitaminsAr);
    expect(find.text('لا توجد منتجات في هذه الفئة'), findsOneWidget);
    expect(find.byType(ProductCard), findsNothing);
    await tester.tap(_chip('فيتامين سي'));
    await tester.pumpAndSettle();
    expect(find.text('لا توجد منتجات في هذه الفئة'), findsOneWidget);
  });

  testWidgets('cart: badge follows additions; the icon opens the cart tab', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    await _openFromHome(tester, _vitaminsAr);
    Finder badge(String n) => find.descendant(
      of: find.byType(CategoryPage),
      matching: find.descendant(
        of: find.byType(CountBadge),
        matching: find.text(n),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(CategoryPage),
        matching: find.byType(CountBadge),
      ),
      findsOneWidget,
    );
    expect(badge('1'), findsNothing);

    await tester.tap(
      find.descendant(
        of: _product(104),
        matching: find.widgetWithText(FilledButton, 'أضف للسلة'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(badge('1'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // cart icon (left of the header in Arabic) -> back to main, cart tab
    await tester.tap(
      find
          .descendant(
            of: find.byType(AppPageHeader),
            matching: find.byType(InkResponse),
          )
          .last,
    );
    await tester.pumpAndSettle();
    expect(find.byType(CategoryPage), findsNothing);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.text('السلة'), findsNWidgets(2)); // tab label + page title
  });

  testWidgets('hearts are shared between home and the section page', (
    tester,
  ) async {
    await pumpApp(tester, _session);
    await _openFromHome(tester, _vitaminsAr);
    await tester.tap(
      find.descendant(
        of: _product(104),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'إضافة إلى المفضلة',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: _product(104), matching: find.byIcon(Icons.favorite)),
      findsOneWidget,
    );
    await tester.tap(
      find
          .descendant(
            of: find.byType(AppPageHeader),
            matching: find.byType(InkResponse),
          )
          .first,
    );
    await tester.pumpAndSettle();
    final home = find.byKey(const ValueKey('product-104'));
    await tester.scrollUntilVisible(
      home,
      300,
      scrollable: find
          .descendant(
            of: find.byType(RefreshIndicator),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: home.first, matching: find.byIcon(Icons.favorite)),
      findsOneWidget,
    );
  });

  testWidgets('section page (EN): mirrored header, chips and grid', (
    tester,
  ) async {
    await pumpApp(tester, _english);
    await _openFromHome(tester, _vitaminsEn);
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;

    expect(directionOf(tester), TextDirection.ltr);
    final buttons = find.descendant(
      of: find.byType(AppPageHeader),
      matching: find.byType(InkResponse),
    );
    expect(tester.getCenter(buttons.first).dx, lessThan(width / 2));
    expect(tester.getCenter(buttons.last).dx, greaterThan(width / 2));
    expect(_chip('All'), findsOneWidget);
    expect(
      tester.getCenter(_chip('All')).dx,
      lessThan(tester.getCenter(_chip('Omega-3')).dx),
    );
    expect(
      tester.getCenter(_product(104)).dx,
      lessThan(tester.getCenter(_product(105)).dx),
    );
    expect(tester.getTopLeft(_product(104)).dx, closeTo(16.w, 0.5));

    await _tapChip(tester, 'Vitamin C');
    expect(find.byType(ProductCard), findsOneWidget);
    expect(_product(104), findsOneWidget);
    expect(_chipColor(tester, 'Vitamin C'), const Color(0xFF267B00));
    expect(tester.takeException(), isNull);
  });

  testWidgets('small phone (iPhone SE): no overflow, both languages', (
    tester,
  ) async {
    for (final prefs in [_session, _english]) {
      await pumpApp(tester, prefs, size: const Size(750, 1334));
      await _openFromHome(
        tester,
        prefs == _session ? _vitaminsAr : _vitaminsEn,
      );
      await tester.drag(find.byType(ProductCard).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
