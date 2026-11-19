import '../../../../core/utils/result.dart';
import '../entities/category_page_data.dart';
import '../entities/home_data.dart';
import '../entities/product.dart';
import '../entities/product_category.dart';
import '../entities/support_contact.dart';

/// Home page data. [languageCode] (`ar` / `en`) picks the language of every
/// text in the result.
abstract interface class HomeRepository {
  Future<Result<HomeData>> getHome(String languageCode);

  /// The support team's contact details.
  Future<Result<SupportContact>> getSupportContact();

  /// The root categories (sections) with their sub-categories.
  Future<Result<List<ProductCategory>>> getCategories(String languageCode);

  /// The category with [categoryId] (a root or a sub-category) and its
  /// products; a [NotFoundFailure] when there is no such category.
  Future<Result<CategoryPageData>> getCategoryPage(
    int categoryId,
    String languageCode,
  );

  Future<Result<List<Product>>> searchProducts(
    String query,
    String languageCode,
  );
}
