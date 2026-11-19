import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/support_contact.dart';
import '../models/home_banner_model.dart';
import '../models/news_item_model.dart';
import '../models/product_category_model.dart';
import '../models/support_contact_model.dart';
import '../models/product_model.dart';
import 'home_remote_data_source.dart';

/// Real backend implementation: the same `/v1/site` endpoints the website
/// uses.
class ApiHomeRemoteDataSource implements HomeRemoteDataSource {
  const ApiHomeRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> _get(
    String path,
    String languageCode, [
    Map<String, dynamic>? query,
  ]) async => JsonReader.map(
    await _client.get(
      path,
      queryParameters: query,
      headers: {'Accept-Language': languageCode},
    ),
  );

  @override
  Future<SupportContact> fetchSupportContact() async {
    final json = await _get('/v1/site/settings', 'ar');
    final contact = SupportContactModel.tryFromSettings(
      JsonReader.map(json['data']),
    );
    if (contact == null) throw const NotFoundException();
    return contact;
  }

  @override
  Future<List<NewsItemModel>> fetchNews(String languageCode) async {
    final json = await _get('/v1/site/settings', languageCode);
    return NewsItemModel.listFromSetting(
      JsonReader.map(json['data'])['news_bar_items'],
      languageCode,
    );
  }

  @override
  Future<List<HomeBannerModel>> fetchBanners(String languageCode) async {
    final json = await _get('/v1/site/sliders', languageCode, {'is_active': 1});
    return [
      for (final item in JsonReader.mapList(json['data']))
        if (HomeBannerModel.isVisible(item))
          HomeBannerModel.fromJson(item, languageCode),
    ];
  }

  @override
  Future<List<ProductCategoryModel>> fetchCategories(
    String languageCode,
  ) async {
    final json = await _get('/v1/site/categories', languageCode, {
      'is_active': 1,
    });
    return [
      for (final item in JsonReader.mapList(json['data']))
        ProductCategoryModel.fromJson(item, languageCode),
    ];
  }

  @override
  Future<List<ProductModel>> fetchProducts(
    String languageCode, {
    String? search,
  }) async {
    final json = await _get('/v1/site/products/all_products', languageCode, {
      'is_active': 1,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return [
      for (final item in JsonReader.mapList(json['data']))
        ProductModel.fromJson(item, languageCode),
    ];
  }
}
