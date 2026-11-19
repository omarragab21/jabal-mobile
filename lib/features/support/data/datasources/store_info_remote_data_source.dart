import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_reader.dart';
import '../models/store_info_model.dart';
import '../../domain/entities/store_info.dart';

/// Where the store's contact details come from. Throws an `AppException`.
abstract interface class StoreInfoRemoteDataSource {
  Future<StoreInfo> fetchStoreInfo();
}

/// The site settings of the real backend.
class ApiStoreInfoRemoteDataSource implements StoreInfoRemoteDataSource {
  const ApiStoreInfoRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<StoreInfo> fetchStoreInfo() async {
    final json = JsonReader.map(await _client.get('/v1/site/settings'));
    return StoreInfoModel.fromSettings(JsonReader.map(json['data']));
  }
}

/// Demo settings in the shape of the real ones (the store's live values).
class MockStoreInfoRemoteDataSource implements StoreInfoRemoteDataSource {
  const MockStoreInfoRemoteDataSource({
    this.latency = const Duration(milliseconds: 300),
  });

  final Duration latency;

  static const Map<String, dynamic> settings = {
    'whatsapp': 'https://wa.me/966500000000',
    'support_email': 'info@jabel.com',
    'support_phone': '8001240198',
    'social_links': {
      'facebook': 'https://facebook.com/jabel',
      'instagram': 'https://instagram.com/jabel',
      'x_twitter': 'https://x.com/jabel',
      'tiktok': 'https://tiktok.com/@jabel',
      'snapchat': 'https://snapchat.com/add/jabel',
      'youtube': 'https://youtube.com/@jabel',
      'linkedin': 'https://linkedin.com/company/jabel',
    },
  };

  @override
  Future<StoreInfo> fetchStoreInfo() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return StoreInfoModel.fromSettings(settings);
  }
}
