import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../repositories/home_repository.dart';

class SearchProducts {
  const SearchProducts(this._repository);
  final HomeRepository _repository;

  /// Shortest text worth sending to the backend.
  static const int minLength = 2;

  /// A query shorter than [minLength] (after trimming) matches nothing.
  Future<Result<List<Product>>> call(String query, String languageCode) {
    final text = query.trim();
    if (text.length < minLength) return Future.value(const Success([]));
    return _repository.searchProducts(text, languageCode);
  }
}
