import '../../../../core/utils/result.dart';
import '../../../home/domain/entities/product_category.dart';
import '../../../home/domain/repositories/home_repository.dart';

/// The sections of the store (root categories) in the order they are shown,
/// each with its sub-sections.
class GetSections {
  const GetSections(this._repository);
  final HomeRepository _repository;

  Future<Result<List<ProductCategory>>> call(String languageCode) async {
    final result = await _repository.getCategories(languageCode);
    return result.when(
      success: (all) => Success([
        for (final category in all)
          if (category.isRoot) category,
      ]),
      failure: Err.new,
    );
  }
}
