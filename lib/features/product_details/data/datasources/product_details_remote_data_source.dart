import '../../domain/entities/product_details.dart';

/// Where product pages come from. [MockProductDetailsRemoteDataSource] stands
/// in until the API exists; the real one only has to satisfy this contract.
abstract interface class ProductDetailsRemoteDataSource {
  /// Throws `NotFoundException` when there is no product [id].
  Future<ProductDetails> fetchProduct(int id, String languageCode);
}
