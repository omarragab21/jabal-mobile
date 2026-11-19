import '../../../../core/error/exceptions.dart';
import '../../domain/entities/support_contact.dart';
import '../models/home_banner_model.dart';
import '../models/news_item_model.dart';
import '../models/product_category_model.dart';
import '../models/support_contact_model.dart';
import '../models/product_model.dart';
import 'home_remote_data_source.dart';
import 'mock_home_payloads.dart';

/// Demo backend: API-shaped payloads parsed by the real models, after a
/// short fake network delay.
class MockHomeRemoteDataSource implements HomeRemoteDataSource {
  const MockHomeRemoteDataSource({
    this.latency = const Duration(milliseconds: 500),
  });

  final Duration latency;

  Future<T> _respond<T>(T Function() build) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return build();
  }

  @override
  Future<SupportContact> fetchSupportContact() => _respond(() {
    final contact = SupportContactModel.tryFromSettings(mockSettings);
    if (contact == null) throw const NotFoundException();
    return contact;
  });

  @override
  Future<List<NewsItemModel>> fetchNews(String languageCode) => _respond(
    () => NewsItemModel.listFromSetting(mockNewsBarItems, languageCode),
  );

  @override
  Future<List<HomeBannerModel>> fetchBanners(String languageCode) => _respond(
    () => [
      for (final item in mockSliders)
        if (HomeBannerModel.isVisible(item))
          HomeBannerModel.fromJson(item, languageCode),
    ],
  );

  @override
  Future<List<ProductCategoryModel>> fetchCategories(String languageCode) =>
      _respond(
        () => [
          for (final item in mockCategories)
            ProductCategoryModel.fromJson(item, languageCode),
        ],
      );

  @override
  Future<List<ProductModel>> fetchProducts(
    String languageCode, {
    String? search,
  }) => _respond(() {
    final query = (search ?? '').trim().toLowerCase();
    return [
      for (final item in mockProducts(languageCode))
        if (query.isEmpty || _matches(item, query))
          ProductModel.fromJson(item, languageCode),
    ];
  });

  /// Like the backend: the product or its category name contains the text,
  /// in either language.
  static bool _matches(Map<String, dynamic> item, String query) {
    final translations = item['translations'] as Map<String, dynamic>;
    final category =
        (item['category'] as Map<String, dynamic>)['translations']
            as Map<String, dynamic>;
    return [
      for (final source in [translations, category])
        for (final language in source.values)
          ((language as Map<String, dynamic>)['name'] as String).toLowerCase(),
    ].any((name) => name.contains(query));
  }
}
