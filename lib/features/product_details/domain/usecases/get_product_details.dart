import '../../../../core/utils/result.dart';
import '../entities/product_details.dart';
import '../repositories/product_details_repository.dart';

class GetProductDetails {
  const GetProductDetails(this._repository);
  final ProductDetailsRepository _repository;

  Future<Result<ProductDetails>> call(int id, String languageCode) =>
      _repository.getProductDetails(id, languageCode);
}
