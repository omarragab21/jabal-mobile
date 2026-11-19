import '../../domain/entities/product_details.dart';
import '../models/product_details_model.dart';
import 'mock_product_details_payloads.dart';
import 'product_details_remote_data_source.dart';

/// Demo backend: an API-shaped payload parsed by the real model, after a short
/// fake network delay.
class MockProductDetailsRemoteDataSource
    implements ProductDetailsRemoteDataSource {
  const MockProductDetailsRemoteDataSource({
    this.latency = const Duration(milliseconds: 500),
  });

  final Duration latency;

  @override
  Future<ProductDetails> fetchProduct(int id, String languageCode) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return ProductDetailsModel.fromJson(
      mockProductPayload(id, languageCode),
      languageCode,
    );
  }
}
