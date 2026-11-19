import '../models/home_banner_model.dart';
import '../models/news_item_model.dart';
import '../models/product_category_model.dart';
import '../../domain/entities/support_contact.dart';
import '../models/product_model.dart';

/// Where the home page data comes from. Every call takes the language code
/// (`ar` / `en`) the texts should be in and throws an `AppException` on
/// failure.
abstract interface class HomeRemoteDataSource {
  Future<List<NewsItemModel>> fetchNews(String languageCode);

  Future<List<HomeBannerModel>> fetchBanners(String languageCode);

  Future<List<ProductCategoryModel>> fetchCategories(String languageCode);

  /// The support team's WhatsApp number; throws `NotFoundException` when the
  /// store has not set one.
  Future<SupportContact> fetchSupportContact();

  /// All active products, or only those matching [search].
  Future<List<ProductModel>> fetchProducts(
    String languageCode, {
    String? search,
  });
}
