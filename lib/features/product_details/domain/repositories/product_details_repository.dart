import '../../../../core/utils/result.dart';
import '../entities/product_details.dart';

abstract interface class ProductDetailsRepository {
  /// The product with [id] in [languageCode] (`ar` / `en`); a
  /// `NotFoundFailure` when there is no such product.
  Future<Result<ProductDetails>> getProductDetails(int id, String languageCode);
}
