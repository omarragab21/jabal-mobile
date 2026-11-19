import '../../../../core/utils/result.dart';
import '../entities/category_page_data.dart';
import '../repositories/home_repository.dart';

class GetCategoryPage {
  const GetCategoryPage(this._repository);
  final HomeRepository _repository;

  Future<Result<CategoryPageData>> call(int categoryId, String languageCode) =>
      _repository.getCategoryPage(categoryId, languageCode);
}
