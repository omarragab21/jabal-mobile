import 'package:dr_jabel/core/error/exceptions.dart';
import 'package:dr_jabel/core/error/failures.dart';
import 'package:dr_jabel/core/platform/link_opener.dart';
import 'package:dr_jabel/core/utils/result.dart';
import 'package:dr_jabel/features/cart/data/repositories/mock_cart_repository.dart';
import 'package:dr_jabel/features/cart/domain/usecases/add_to_cart.dart';
import 'package:dr_jabel/features/cart/domain/usecases/watch_cart_count.dart';
import 'package:dr_jabel/features/home/data/datasources/home_remote_data_source.dart';
import 'package:dr_jabel/features/home/data/datasources/mock_home_remote_data_source.dart';
import 'package:dr_jabel/features/home/data/models/home_banner_model.dart';
import 'package:dr_jabel/features/home/data/models/news_item_model.dart';
import 'package:dr_jabel/features/home/data/models/product_category_model.dart';
import 'package:dr_jabel/features/home/data/models/product_model.dart';
import 'package:dr_jabel/features/home/data/repositories/home_repository_impl.dart';
import 'package:dr_jabel/features/home/domain/entities/category_page_data.dart';
import 'package:dr_jabel/features/home/domain/entities/home_data.dart';
import 'package:dr_jabel/features/home/domain/entities/product.dart';
import 'package:dr_jabel/features/home/domain/entities/support_contact.dart';
import 'package:dr_jabel/features/home/domain/usecases/contact_support.dart';
import 'package:dr_jabel/features/home/domain/entities/product_category.dart';
import 'package:dr_jabel/features/home/domain/repositories/home_repository.dart';
import 'package:dr_jabel/features/home/domain/usecases/get_category_page.dart';
import 'package:dr_jabel/features/home/domain/usecases/get_home_data.dart';
import 'package:dr_jabel/features/home/domain/usecases/search_products.dart';
import 'package:dr_jabel/features/home/presentation/cubit/category_cubit.dart';
import 'package:dr_jabel/features/home/presentation/cubit/category_state.dart';
import 'package:dr_jabel/features/home/presentation/cubit/favorites_cubit.dart';
import 'package:dr_jabel/features/home/presentation/cubit/home_cubit.dart';
import 'package:dr_jabel/features/home/presentation/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _fast = MockHomeRemoteDataSource(latency: Duration.zero);

class _NoopOpener implements LinkOpener {
  @override
  Future<bool> open(Uri uri) async => true;
}

/// The real API product (id 6), trimmed.
const Map<String, dynamic> _apiProduct = {
  'id': 6,
  'category_id': 64,
  'price': 6.5,
  'discount_price': null,
  'final_price': 6.5,
  'has_discount': false,
  'number': 118,
  'is_active': true,
  'is_featured': true,
  'attributes': {
    'اللون': [
      {'id': 2, 'name': 'أحمر', 'value_code': '#ab1717'},
    ],
    'الحجم': [
      {'id': 1, 'name': '50 مل', 'value_code': null},
    ],
  },
  'name': 'فيتامين سي',
  'translations': {
    'en': {'name': 'Vitamin C'},
    'ar': {'name': 'فيتامين سي'},
  },
  'images': [
    {
      'id': 6,
      'image_url': 'https://x/full.jpg',
      'thumb_url': 'https://x/t.jpg',
    },
  ],
  'category': {
    'id': 64,
    'name': 'الفيتامينات',
    'translations': {
      'en': {'name': 'Vitamins'},
      'ar': {'name': 'الفيتامينات'},
    },
  },
};

class _FailingRemote implements HomeRemoteDataSource {
  @override
  Future<SupportContact> fetchSupportContact() =>
      Future.error(const NetworkException());

  @override
  Future<List<HomeBannerModel>> fetchBanners(String languageCode) async => [];
  @override
  Future<List<ProductCategoryModel>> fetchCategories(String languageCode) =>
      Future.error(const NetworkException());
  @override
  Future<List<NewsItemModel>> fetchNews(String languageCode) async => [];
  @override
  Future<List<ProductModel>> fetchProducts(
    String languageCode, {
    String? search,
  }) => Future.error(const NetworkException());
}

HomeCubit _cubit(HomeRemoteDataSource remote, {MockCartRepository? cart}) {
  final repository = HomeRepositoryImpl(remote);
  return HomeCubit(
    getHomeData: GetHomeData(repository),
    addToCart: AddToCart(cart ?? MockCartRepository()),
    contactSupport: ContactSupport(repository, _NoopOpener()),
  );
}

void main() {
  group('ProductModel', () {
    test('reads the API shape in the requested language', () {
      final ar = ProductModel.fromJson(_apiProduct, 'ar');
      expect(ar.id, 6);
      expect(ar.name, 'فيتامين سي');
      expect(ar.categoryId, 64);
      expect(ar.categoryName, 'الفيتامينات');
      expect(ar.price, 6.5);
      expect(ar.hasDiscount, isFalse);
      expect(ar.oldPrice, isNull);
      expect(ar.imageUrl, 'https://x/t.jpg');
      expect(ar.stock, 118);
      expect(ar.inStock, isTrue);
      expect(ar.isFeatured, isTrue);
      // the colour option is skipped: the size is the label
      expect(ar.sizeLabel, '50 مل');

      final en = ProductModel.fromJson(_apiProduct, 'en');
      expect(en.name, 'Vitamin C');
      expect(en.categoryName, 'Vitamins');
    });

    test('discount: old price and percent', () {
      final p = ProductModel.fromJson({
        ..._apiProduct,
        'price': 5,
        'discount_price': 4.25,
        'final_price': 4.25,
      }, 'ar');
      expect(p.hasDiscount, isTrue);
      expect(p.finalPrice, 4.25);
      expect(p.oldPrice, 5);
      expect(p.discountPercent, 15);
    });

    test('survives loose and broken payloads', () {
      final p = ProductModel.fromJson({
        'id': '9',
        'price': '12.50',
        'final_price': '99', // above the list price: ignored
        'attributes': <dynamic>[], // the API sends [] when there are none
        'images': null,
        'is_active': '0',
        'name': 'Only name',
      }, 'en');
      expect(p.id, 9);
      expect(p.price, 12.5);
      expect(p.finalPrice, 12.5);
      expect(p.hasDiscount, isFalse);
      expect(p.attributes, isEmpty);
      expect(p.sizeLabel, isNull);
      expect(p.imageUrl, isNull);
      expect(p.isActive, isFalse);
      expect(p.inStock, isFalse);
      expect(p.name, 'Only name');
      expect(p.categoryName, '');
    });

    test('a missing translation falls back to the other language', () {
      final p = ProductModel.fromJson({
        'id': 1,
        'price': 1,
        'translations': {
          'ar': {'name': 'عربي فقط'},
        },
      }, 'en');
      expect(p.name, 'عربي فقط');
    });
  });

  group('NewsItemModel', () {
    const setting = [
      {'id': 'a', 'text_ar': 'خبر', 'text_en': 'News', 'is_active': true},
      {'id': 'b', 'text_ar': 'متوقف', 'text_en': 'Off', 'is_active': false},
      {'id': 'c', 'text_ar': 'عربي فقط', 'text_en': '', 'is_active': 1},
      {'id': 'd', 'text_ar': '  ', 'text_en': null},
    ];

    test('keeps active, non-empty items in the language', () {
      final ar = NewsItemModel.listFromSetting(setting, 'ar');
      expect(ar.map((n) => n.text), ['خبر', 'عربي فقط']);
      final en = NewsItemModel.listFromSetting(setting, 'en');
      expect(en.map((n) => n.text), ['News', 'عربي فقط']);
    });

    test('accepts a JSON string and rejects garbage', () {
      expect(
        NewsItemModel.listFromSetting(
          '[{"text_ar":"خبر","text_en":"News"}]',
          'en',
        ).single.text,
        'News',
      );
      expect(NewsItemModel.listFromSetting('not json', 'ar'), isEmpty);
      expect(NewsItemModel.listFromSetting(null, 'ar'), isEmpty);
    });
  });

  test('HomeData.sectionsOf groups by category and drops empty ones', () {
    Product product(int id, int categoryId) => Product(
      id: id,
      name: 'p$id',
      categoryId: categoryId,
      categoryName: 'c$categoryId',
      price: 1,
      finalPrice: 1,
    );
    const categories = [
      ProductCategory(id: 2, name: 'two'),
      ProductCategory(id: 1, name: 'one'),
      ProductCategory(id: 3, name: 'empty'),
    ];
    final sections = HomeData.sectionsOf(categories, [
      product(10, 1),
      product(11, 2),
      product(12, 1),
    ]);
    expect(sections.map((s) => s.title), ['two', 'one']);
    expect(sections[1].products.map((p) => p.id), [10, 12]);
  });

  group('repository on the mock backend', () {
    const repository = HomeRepositoryImpl(_fast);

    test('home: news, banners, categories, sections', () async {
      final result = await repository.getHome('ar');
      final data = (result as Success<HomeData>).data;
      expect(data.news, hasLength(5)); // the switched-off item is gone
      expect(data.banners.map((b) => b.order), [1, 2]);
      expect(data.categories, hasLength(8));
      expect(data.sections, hasLength(8));
      for (final section in data.sections) {
        expect(section.products, isNotEmpty);
        expect(
          section.products.every(
            (p) => section.category.allIds.contains(p.categoryId),
          ),
          isTrue,
        );
      }
    });

    test('english texts', () async {
      final data = ((await repository.getHome('en')) as Success<HomeData>).data;
      expect(data.categories.first.name, 'Vitamins & supplements');
      final spray = data.sections
          .expand((s) => s.products)
          .firstWhere((p) => p.id == 101);
      expect(spray.name, 'Saline nasal spray');
      expect(spray.sizeLabel, '30 ml');
      expect(spray.finalPrice, 4.25);
      expect(spray.oldPrice, 5);
    });

    test('search matches either language and the category name', () async {
      Future<List<int>> ids(String q, String lang) async =>
          ((await repository.searchProducts(q, lang)) as Success<List<Product>>)
              .data
              .map((p) => p.id)
              .toList();
      expect(await ids('بخاخ', 'ar'), [101, 103]);
      expect(await ids('SPRAY', 'ar'), [101, 103]);
      // "Vitamins & supplements" is a category name; 104 and 120 match by name
      expect(await ids('vitamins', 'en'), [105, 120]);
      expect(await ids('vitamin', 'en'), [104, 105, 120]);
      expect(await ids('zzz', 'en'), isEmpty);
    });

    test('a failing call becomes a failure', () async {
      final result = await HomeRepositoryImpl(_FailingRemote()).getHome('ar');
      expect((result as Err<HomeData>).failure, isA<NetworkFailure>());
    });
  });

  test('SearchProducts ignores queries under two characters', () async {
    const search = SearchProducts(HomeRepositoryImpl(_fast));
    expect(
      ((await search(' ب ', 'ar')) as Success<List<Product>>).data,
      isEmpty,
    );
    expect(
      ((await search(' بخاخ ', 'ar')) as Success<List<Product>>).data,
      hasLength(2),
    );
  });

  group('HomeCubit', () {
    test('load -> ready; reload in another language', () async {
      final cubit = _cubit(_fast);
      expect(cubit.state.status, HomeStatus.loading);
      await cubit.load('ar');
      expect(cubit.state.status, HomeStatus.ready);
      expect(cubit.state.data.categories.first.name, 'الفيتامينات والمكملات');
      await cubit.load('en');
      expect(cubit.state.data.categories.first.name, 'Vitamins & supplements');
      await cubit.close();
    });

    test('load failure -> failed with the failure', () async {
      final cubit = _cubit(_FailingRemote());
      await cubit.load('ar');
      expect(cubit.state.status, HomeStatus.failed);
      expect(cubit.state.failure, isA<NetworkFailure>());
      await cubit.close();
    });

    test('add to cart reaches the cart', () async {
      final cart = MockCartRepository();
      final counts = <int>[];
      final sub = cart.watchItemCount().listen(counts.add);
      final cubit = _cubit(_fast, cart: cart);
      await cubit.load('ar');
      final product = cubit.state.data.sections.first.products.first;
      await cubit.addToCart(product);
      await cubit.addToCart(product);
      await pumpEventQueue();
      expect(counts, [0, 1, 2]);
      await sub.cancel();
      await cubit.close();
    });
  });

  test('FavoritesCubit toggles a product', () {
    final favorites = FavoritesCubit();
    const product = Product(
      id: 5,
      name: 'p',
      categoryId: 1,
      categoryName: 'c',
      price: 1,
      finalPrice: 1,
    );
    expect(favorites.isFavorite(product), isFalse);
    favorites.toggle(product);
    expect(favorites.isFavorite(product), isTrue);
    favorites.toggle(product);
    expect(favorites.isFavorite(product), isFalse);
    favorites.close();
  });

  group('categories with sub-categories', () {
    const repository = HomeRepositoryImpl(_fast);

    Future<CategoryPageData> page(int id, [String lang = 'ar']) async =>
        ((await repository.getCategoryPage(id, lang))
                as Success<CategoryPageData>)
            .data;

    test('the API nests sub_categories, ordered by sort_order', () async {
      final categories = await _fast.fetchCategories('ar');
      final vitamins = categories.firstWhere((c) => c.id == 64);
      expect(vitamins.subCategories.map((c) => c.id), [641, 642, 643, 644]);
      expect(vitamins.subCategories.first.parentId, 64);
      expect(vitamins.allIds, {64, 641, 642, 643, 644});
      expect(vitamins.find(643)?.name, 'فيتامينات ومناعة');
      expect(vitamins.find(12), isNull);
      expect(vitamins.find(641)!.hasSubCategories, isFalse);
    });

    test('inactive sub-categories are dropped', () {
      final category = ProductCategoryModel.fromJson({
        'id': 1,
        'name': 'root',
        'sub_categories': [
          {'id': 2, 'name': 'on', 'sort_order': 2, 'is_active': true},
          {'id': 3, 'name': 'off', 'is_active': false},
          {'id': 4, 'name': 'first', 'sort_order': 1},
        ],
      }, 'ar');
      expect(category.subCategories.map((c) => c.id), [4, 2]);
    });

    test('a root page has every product of its sub-categories', () async {
      final data = await page(64);
      expect(data.category.name, 'الفيتامينات والمكملات');
      expect(data.category.subCategories, hasLength(4));
      expect(data.products.map((p) => p.id), [104, 105, 106, 119, 120]);
    });

    test('a sub-category page has only its own products, no chips', () async {
      final data = await page(643);
      expect(data.category.hasSubCategories, isFalse);
      expect(data.products.map((p) => p.id), [105, 120]);
      expect(data.products.first.categoryName, 'فيتامينات ومناعة');
    });

    test('english names', () async {
      expect((await page(66, 'en')).category.name, 'Mother & baby');
    });

    test('unknown category -> NotFoundFailure', () async {
      final result = await repository.getCategoryPage(9999, 'ar');
      expect((result as Err<CategoryPageData>).failure, isA<NotFoundFailure>());
    });

    test('home sections include the sub-category products', () async {
      final data = ((await repository.getHome('ar')) as Success<HomeData>).data;
      final vitamins = data.sections.firstWhere((s) => s.category.id == 64);
      expect(vitamins.products.map((p) => p.id), [104, 105, 106, 119, 120]);
    });

    test('CategoryCubit: load, language, failure, cart count', () async {
      final cart = MockCartRepository(initial: {1: 3});
      final repo = HomeRepositoryImpl(_fast);
      CategoryCubit make(HomeRepository r, int id) => CategoryCubit(
        categoryId: id,
        getCategoryPage: GetCategoryPage(r),
        addToCart: AddToCart(cart),
        watchCartCount: WatchCartCount(cart),
      );
      final cubit = make(repo, 642);
      expect(cubit.state.status, CategoryStatus.loading);
      await cubit.load('en');
      expect(cubit.state.status, CategoryStatus.ready);
      expect(cubit.state.data?.category.name, 'Vitamin C');
      expect(cubit.state.data?.products.map((p) => p.id), [104]);
      expect(cubit.state.cartCount, 3);
      await cubit.addToCart(cubit.state.data!.products.first);
      await pumpEventQueue();
      expect(cubit.state.cartCount, 4);
      await cubit.close();

      final missing = make(repo, 9999);
      await missing.load('ar');
      expect(missing.state.status, CategoryStatus.failed);
      expect(missing.state.failure, isA<NotFoundFailure>());
      await missing.close();

      final broken = make(HomeRepositoryImpl(_FailingRemote()), 64);
      await broken.load('ar');
      expect(broken.state.failure, isA<NetworkFailure>());
      await broken.close();
    });
  });
}
