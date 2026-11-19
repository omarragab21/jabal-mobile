import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category_page_data.dart';
import '../../domain/entities/home_banner.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/support_contact.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  @override
  Future<Result<HomeData>> getHome(String languageCode) => guard(() async {
    // Future.wait rethrows the first failure as-is, so `guard` can map it.
    final results = await Future.wait<Object?>([
      _remote.fetchNews(languageCode),
      _remote.fetchBanners(languageCode),
      _remote.fetchCategories(languageCode),
      _remote.fetchProducts(languageCode),
    ]);
    final news = results[0]! as List<NewsItem>;
    final banners = results[1]! as List<HomeBanner>;
    final categories = results[2]! as List<ProductCategory>;
    final products = results[3]! as List<Product>;
    final sortedBanners = [...banners]
      ..sort((a, b) => a.order.compareTo(b.order));
    return HomeData(
      news: news,
      banners: sortedBanners,
      categories: categories,
      sections: HomeData.sectionsOf(categories, [
        for (final product in products)
          if (product.isActive) product,
      ]),
    );
  });

  @override
  Future<Result<SupportContact>> getSupportContact() =>
      guard(_remote.fetchSupportContact);

  @override
  Future<Result<List<ProductCategory>>> getCategories(String languageCode) =>
      guard(() => _remote.fetchCategories(languageCode));

  @override
  Future<Result<CategoryPageData>> getCategoryPage(
    int categoryId,
    String languageCode,
  ) => guard(() async {
    final results = await Future.wait<Object?>([
      _remote.fetchCategories(languageCode),
      _remote.fetchProducts(languageCode),
    ]);
    final categories = results[0]! as List<ProductCategory>;
    final products = results[1]! as List<Product>;
    ProductCategory? category;
    for (final root in categories) {
      category = root.find(categoryId);
      if (category != null) break;
    }
    if (category == null) throw const NotFoundException();
    final ids = category.allIds;
    return CategoryPageData(
      category: category,
      products: [
        for (final product in products)
          if (product.isActive && ids.contains(product.categoryId)) product,
      ],
    );
  });

  @override
  Future<Result<List<Product>>> searchProducts(
    String query,
    String languageCode,
  ) => guard(() => _remote.fetchProducts(languageCode, search: query));
}
