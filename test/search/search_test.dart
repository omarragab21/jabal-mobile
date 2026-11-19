import 'package:dr_jabel/core/error/exceptions.dart';
import 'package:dr_jabel/core/error/failures.dart';
import 'package:dr_jabel/core/storage/storage_keys.dart';
import 'package:dr_jabel/core/utils/result.dart';
import 'package:dr_jabel/features/cart/data/repositories/mock_cart_repository.dart';
import 'package:dr_jabel/features/cart/domain/usecases/add_to_cart.dart';
import 'package:dr_jabel/features/home/data/datasources/mock_home_remote_data_source.dart';
import 'package:dr_jabel/features/home/data/models/product_model.dart';
import 'package:dr_jabel/features/home/data/repositories/home_repository_impl.dart';
import 'package:dr_jabel/features/home/domain/usecases/contact_support.dart';
import 'package:dr_jabel/features/home/domain/usecases/search_products.dart';
import 'package:dr_jabel/features/home/presentation/pages/home_page.dart';
import 'package:dr_jabel/features/home/presentation/widgets/home_search_field.dart';
import 'package:dr_jabel/features/home/presentation/widgets/product_card.dart';
import 'package:dr_jabel/features/product_details/presentation/pages/product_details_page.dart';
import 'package:dr_jabel/features/search/data/datasources/mock_search_remote_data_source.dart';
import 'package:dr_jabel/features/search/data/repositories/search_repository_impl.dart';
import 'package:dr_jabel/features/search/domain/repositories/search_repository.dart';
import 'package:dr_jabel/features/search/domain/services/search_text.dart';
import 'package:dr_jabel/features/search/domain/usecases/get_search_suggestions.dart';
import 'package:dr_jabel/features/search/presentation/cubit/search_cubit.dart';
import 'package:dr_jabel/features/search/presentation/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _session = {
  StorageKeys.onboardingSeen: true,
  StorageKeys.authToken: 'mock-token-1',
  StorageKeys.authUser:
      '{"id":"1","name":"Ahmad Ali","phone":"+962791234567","email":null}',
};

const _fast = MockSearchRemoteDataSource(latency: Duration.zero);

class _FakeSuggestions implements SearchRepository {
  _FakeSuggestions(this.answer);

  final Result<List<String>> Function(String query) answer;
  final List<String> asked = [];

  @override
  Future<Result<List<String>>> getSuggestions(
    String query,
    String languageCode,
  ) async {
    asked.add(query);
    return answer(query);
  }
}

class _FailingSearch extends MockHomeRemoteDataSource {
  const _FailingSearch() : super(latency: Duration.zero);

  @override
  Future<List<ProductModel>> fetchProducts(
    String languageCode, {
    String? search,
  }) => Future.error(const NetworkException());
}

class _NoopOpener extends RecordingLinkOpener {
  _NoopOpener();
}

SearchCubit _cubit({
  SearchRepository? suggestions,
  MockHomeRemoteDataSource? home,
  RecordingLinkOpener? opener,
  Duration debounce = Duration.zero,
}) {
  final repository = HomeRepositoryImpl(
    home ?? const MockHomeRemoteDataSource(latency: Duration.zero),
  );
  return SearchCubit(
    getSuggestions: GetSearchSuggestions(
      suggestions ?? const SearchRepositoryImpl(_fast),
    ),
    searchProducts: SearchProducts(repository),
    addToCart: AddToCart(MockCartRepository()),
    contactSupport: ContactSupport(repository, opener ?? _NoopOpener()),
    suggestionDebounce: debounce,
  );
}

void main() {
  group('SearchText', () {
    test('folds Arabic spellings of the same word together', () {
      expect(
        SearchText.normalize('فِيتَامِين أ'),
        SearchText.normalize('فيتامين ا'),
      );
      expect(SearchText.normalize('مدرسة'), SearchText.normalize('مدرسه'));
      expect(SearchText.normalize('  Vitamin   D '), 'vitamin d');
    });

    test('every word of the query must be in the text', () {
      expect(SearchText.matches('فيتامين د3 5000 وحدة', 'فيتامين د'), isTrue);
      expect(SearchText.matches('Vitamin D3', 'vit d'), isTrue);
      expect(SearchText.matches('Vitamin D3', 'vit k'), isFalse);
      expect(SearchText.matches('anything', '   '), isFalse);
      expect(SearchText.matches('أوميغا 3', 'اوميغا'), isTrue);
    });

    test('a text that starts with the query ranks first', () {
      expect(SearchText.rank('فيتامين د', 'فيتامين'), 0);
      expect(SearchText.rank('مكمل فيتامين', 'فيتامين'), 1);
      expect(SearchText.rank('xفيتامين', 'فيتامين'), 2);
    });
  });

  group('MockSearchRemoteDataSource', () {
    test('suggests the phrases and the shop names that match', () async {
      final list = await _fast.fetchSuggestions('فيتامين', 'ar');
      expect(list, containsAll(['فيتامين أ', 'فيتامين د', 'فيتامين ك']));
      // the shop's own product name is a suggestion too
      expect(list, contains('فيتامين د3 5000 وحدة'));
    });

    test('phrases that start with the text come before the others', () async {
      final list = await _fast.fetchSuggestions('فيتامين', 'ar');
      final firstLoose = list.indexWhere(
        (s) => SearchText.rank(s, 'فيتامين') > 0,
      );
      if (firstLoose >= 0) {
        expect(
          list
              .sublist(firstLoose)
              .every((s) => SearchText.rank(s, 'فيتامين') > 0),
          isTrue,
        );
      }
      expect(
        list.first,
        'فيتامين أ',
        reason: 'curated phrases keep their order',
      );
    });

    test('English has its own texts', () async {
      final list = await _fast.fetchSuggestions('vitamin d', 'en');
      expect(list, contains('Vitamin D'));
      expect(list.every((s) => SearchText.matches(s, 'vitamin d')), isTrue);
    });

    test('nothing matches nonsense', () async {
      expect(await _fast.fetchSuggestions('zzzz', 'en'), isEmpty);
    });
  });

  group('GetSearchSuggestions', () {
    test('a blank text asks nothing', () async {
      final repository = _FakeSuggestions((_) => const Success(['x']));
      final result = await GetSearchSuggestions(repository)('   ', 'ar');
      expect(result.when(success: (l) => l, failure: (_) => ['err']), isEmpty);
      expect(repository.asked, isEmpty);
    });

    test('trims, drops repeats and keeps the first eight', () async {
      final repository = _FakeSuggestions(
        (_) => Success([' a ', 'a', '', for (var i = 0; i < 20; i++) 'item$i']),
      );
      final list = (await GetSearchSuggestions(repository)(
        ' q ',
        'ar',
      )).when(success: (l) => l, failure: (_) => <String>[]);
      expect(repository.asked, ['q']);
      expect(list, hasLength(GetSearchSuggestions.maxCount));
      expect(list.first, 'a');
      expect(list.toSet(), hasLength(list.length));
    });

    test('a failure is passed on', () async {
      final repository = _FakeSuggestions((_) => const Err(NetworkFailure()));
      (await GetSearchSuggestions(repository)('q', 'ar')).when(
        success: (_) => fail('should fail'),
        failure: (f) => expect(f, isA<NetworkFailure>()),
      );
    });
  });

  group('SearchCubit', () {
    test('typing shows the suggestions; clearing empties the screen', () async {
      final cubit = _cubit()..setLanguage('ar');
      expect(cubit.state.phase, SearchPhase.idle);

      cubit.queryChanged('  فيتامين ');
      expect(cubit.state.phase, SearchPhase.suggesting);
      expect(cubit.state.query, 'فيتامين');
      await pumpEventQueue();
      expect(cubit.state.suggestions, contains('فيتامين أ'));

      cubit.queryChanged('');
      expect(cubit.state, const SearchState());
      await cubit.close();
    });

    test('the old suggestions stay while the new ones load', () async {
      final cubit = _cubit()..setLanguage('ar');
      cubit.queryChanged('فيتامين');
      await pumpEventQueue();
      final before = cubit.state.suggestions;
      expect(before, isNotEmpty);

      cubit.queryChanged('فيتامين د');
      expect(cubit.state.suggestions, before, reason: 'no blinking');
      await pumpEventQueue();
      expect(cubit.state.suggestions, isNot(before));
      await cubit.close();
    });

    test('only the latest suggestions answer is used', () async {
      final slow = _SlowThenFast();
      final cubit = _cubit(suggestions: slow)..setLanguage('ar');
      cubit.queryChanged('slow');
      cubit.queryChanged('fast');
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(cubit.state.query, 'fast');
      expect(cubit.state.suggestions, ['fast result']);
      await cubit.close();
    });

    test('typing waits for a pause before asking', () async {
      final repository = _FakeSuggestions((q) => Success(['$q!']));
      final cubit = _cubit(
        suggestions: repository,
        debounce: const Duration(milliseconds: 40),
      )..setLanguage('ar');
      cubit.queryChanged('ف');
      cubit.queryChanged('في');
      cubit.queryChanged('فيت');
      expect(repository.asked, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(repository.asked, ['فيت'], reason: 'one call for the last text');
      expect(cubit.state.suggestions, ['فيت!']);
      await cubit.close();
    });

    test('failing suggestions leave the field usable', () async {
      final cubit = _cubit(
        suggestions: _FakeSuggestions((_) => const Err(NetworkFailure())),
      )..setLanguage('ar');
      cubit.queryChanged('فيتامين');
      await pumpEventQueue();
      expect(cubit.state.phase, SearchPhase.suggesting);
      expect(cubit.state.suggestions, isEmpty);

      await cubit.submit('فيتامين');
      expect(cubit.state.phase, SearchPhase.results);
      await cubit.close();
    });

    test('submitting searches the products', () async {
      final cubit = _cubit()..setLanguage('ar');
      final future = cubit.submit('  بخاخ ');
      expect(cubit.state.phase, SearchPhase.searching);
      expect(cubit.state.query, 'بخاخ');
      await future;
      expect(cubit.state.phase, SearchPhase.results);
      expect(cubit.state.results.map((p) => p.id), [101, 103]);
      expect(cubit.state.hasNoResults, isFalse);
      await cubit.close();
    });

    test('a search with no match is a result with no products', () async {
      final cubit = _cubit()..setLanguage('ar');
      await cubit.submit('زززز');
      expect(cubit.state.phase, SearchPhase.results);
      expect(cubit.state.hasNoResults, isTrue);
      await cubit.close();
    });

    test('a blank submit does nothing', () async {
      final cubit = _cubit()..setLanguage('ar');
      await cubit.submit('   ');
      expect(cubit.state.phase, SearchPhase.idle);
      await cubit.close();
    });

    test('editing the text after a search goes back to suggestions', () async {
      final cubit = _cubit()..setLanguage('ar');
      await cubit.submit('بخاخ');
      expect(cubit.state.results, isNotEmpty);

      cubit.queryChanged('بخا');
      expect(cubit.state.phase, SearchPhase.suggesting);
      expect(cubit.state.results, isEmpty);
      await cubit.close();
    });

    test('a failing search fails, and retry runs it again', () async {
      final cubit = _cubit(home: const _FailingSearch())..setLanguage('ar');
      await cubit.submit('بخاخ');
      expect(cubit.state.phase, SearchPhase.failed);
      expect(cubit.state.query, 'بخاخ');
      await cubit.retry();
      expect(cubit.state.phase, SearchPhase.failed);
      await cubit.close();
    });

    test('the language is the one the screen reports', () async {
      final cubit = _cubit()..setLanguage('en');
      cubit.queryChanged('vitamin d');
      await pumpEventQueue();
      expect(cubit.state.suggestions, contains('Vitamin D'));
      await cubit.close();
    });

    test('asking the pharmacist opens the support chat', () async {
      final opener = RecordingLinkOpener();
      final cubit = _cubit(opener: opener);
      expect(await cubit.askPharmacist('مرحباً'), isTrue);
      expect(opener.opened.single.host, 'wa.me');

      final failing = _cubit(opener: RecordingLinkOpener(result: false));
      expect(await failing.askPharmacist('مرحباً'), isFalse);
      await cubit.close();
      await failing.close();
    });
  });

  group('screen', () {
    Future<void> openSearch(
      WidgetTester tester, {
      RecordingLinkOpener? opener,
    }) async {
      await pumpApp(tester, _session, linkOpener: opener);
      await tester.tap(find.byType(HomeSearchField));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsOneWidget);
    }

    Finder field() => find.descendant(
      of: find.byType(SearchPage),
      matching: find.byType(TextField),
    );

    testWidgets('it opens focused and empty', (tester) async {
      await openSearch(tester);
      expect(find.text('ابحث عن منتج ...'), findsOneWidget);
      expect(tester.widget<TextField>(field()).focusNode?.hasFocus, isTrue);
      expect(find.byType(ProductCard), findsNothing);
      expect(find.byKey(const ValueKey('suggestion-0')), findsNothing);
    });

    testWidgets('typing lists suggestions; tapping one searches', (
      tester,
    ) async {
      await openSearch(tester);
      await tester.enterText(field(), 'فيتامين');
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('suggestion-0')), findsOneWidget);
      expect(find.text('فيتامين أ'), findsOneWidget);
      expect(find.text('فيتامين د'), findsOneWidget);
      expect(
        find.byType(ProductCard),
        findsNothing,
        reason: 'not searched yet',
      );

      await tester.tap(find.text('فيتامين د'));
      await tester.pumpAndSettle();

      // The field shows what was picked, and the products appear.
      expect(tester.widget<TextField>(field()).controller?.text, 'فيتامين د');
      expect(find.byKey(const ValueKey('suggestion-0')), findsNothing);
      expect(find.byType(ProductCard), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the keyboard search key searches what was typed', (
      tester,
    ) async {
      await openSearch(tester);
      await tester.enterText(field(), 'بخاخ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.byType(ProductCard), findsNWidgets(2));
      // two columns
      expect(
        tester.getCenter(find.byKey(const ValueKey('product-101'))).dx,
        greaterThan(
          tester.getCenter(find.byKey(const ValueKey('product-103'))).dx,
        ),
      );
    });

    testWidgets('no match shows the no-results view, with the pharmacist', (
      tester,
    ) async {
      final opener = RecordingLinkOpener();
      await openSearch(tester, opener: opener);
      await tester.enterText(field(), 'زززز');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(
        find.text('عذراً، لم نتمكن من العثور على أي نتائج مطابقة'),
        findsOneWidget,
      );
      expect(
        find.text('جرّب كلمات بحث مختلفة أو تحقق من التهجئة'),
        findsOneWidget,
      );
      expect(find.byType(ProductCard), findsNothing);

      await tester.tap(find.byKey(const ValueKey('search-ask-pharmacist')));
      await tester.pumpAndSettle();
      expect(opener.opened.single.host, 'wa.me');
    });

    testWidgets('clear empties the field and the screen', (tester) async {
      await openSearch(tester);
      await tester.enterText(field(), 'بخاخ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.byType(ProductCard), findsWidgets);

      await tester.tap(find.byTooltip('مسح البحث'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field()).controller?.text, '');
      expect(find.byType(ProductCard), findsNothing);
      expect(find.byTooltip('مسح البحث'), findsNothing);
      expect(tester.widget<TextField>(field()).focusNode?.hasFocus, isTrue);
    });

    testWidgets('a result opens its product page', (tester) async {
      await openSearch(tester);
      await tester.enterText(field(), 'بخاخ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('product-101')));
      await tester.pumpAndSettle();
      expect(find.byType(ProductDetailsPage), findsOneWidget);
    });

    testWidgets('add to cart from the results', (tester) async {
      await openSearch(tester);
      await tester.enterText(field(), 'شامبو');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('product-112')),
          matching: find.widgetWithText(FilledButton, 'أضف للسلة'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('تمت إضافة «شامبو ضد القشرة» إلى السلة'),
        findsOneWidget,
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('the back arrow returns to the shop', (tester) async {
      await openSearch(tester);
      await tester.tap(find.byType(InkResponse).first);
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('small phone, English: no overflow', (tester) async {
      await pumpApp(tester, {
        ..._session,
        StorageKeys.languageCode: 'en',
      }, size: const Size(750, 1334));
      await tester.tap(find.byType(HomeSearchField));
      await tester.pumpAndSettle();
      expect(find.text('Search for a product ...'), findsOneWidget);
      await tester.enterText(field(), 'vitamin');
      await tester.pumpAndSettle();
      expect(find.text('Vitamin D'), findsOneWidget);
      await tester.tap(find.text('Vitamin D'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ProductCard), findsWidgets);
    });
  });
}

/// The first question is answered late, the second at once.
class _SlowThenFast implements SearchRepository {
  @override
  Future<Result<List<String>>> getSuggestions(
    String query,
    String languageCode,
  ) async {
    if (query == 'slow') {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return const Success(['slow result']);
    }
    return const Success(['fast result']);
  }
}
