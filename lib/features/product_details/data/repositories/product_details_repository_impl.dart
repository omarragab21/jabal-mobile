import '../../../../core/utils/result.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/repositories/product_details_repository.dart';
import '../datasources/product_details_remote_data_source.dart';

class ProductDetailsRepositoryImpl implements ProductDetailsRepository {
  const ProductDetailsRepositoryImpl(this._remote);

  final ProductDetailsRemoteDataSource _remote;

  @override
  Future<Result<ProductDetails>> getProductDetails(
    int id,
    String languageCode,
  ) => guard(() => _remote.fetchProduct(id, languageCode));
}
