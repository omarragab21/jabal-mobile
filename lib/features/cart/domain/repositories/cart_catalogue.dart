import '../../../../core/utils/result.dart';
import '../entities/cart.dart';

/// Where the cart reads the products of its rows.
abstract interface class CartCatalogue {
  /// The products with [ids] in [languageCode], in any order. Unknown ids are
  /// left out.
  Future<Result<List<CartProduct>>> productsByIds(
    List<int> ids,
    String languageCode,
  );
}
