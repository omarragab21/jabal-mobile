import '../../../../core/utils/result.dart';
import '../../../home/data/datasources/mock_home_payloads.dart';
import '../../../home/data/models/product_model.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_catalogue.dart';

/// Demo catalogue: the home page's own demo products, parsed by the real
/// product model after a short fake delay.
class MockCartCatalogue implements CartCatalogue {
  const MockCartCatalogue({this.latency = const Duration(milliseconds: 200)});

  final Duration latency;

  @override
  Future<Result<List<CartProduct>>> productsByIds(
    List<int> ids,
    String languageCode,
  ) => guard(() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final wanted = ids.toSet();
    return [
      for (final json in mockProducts(languageCode))
        if (wanted.contains(json['id']))
          _fromModel(ProductModel.fromJson(json, languageCode)),
    ];
  });

  static CartProduct _fromModel(ProductModel p) => CartProduct(
    id: p.id,
    name: p.name,
    price: p.price,
    finalPrice: p.finalPrice,
    imageUrl: p.imageUrl,
    sizeLabel: p.sizeLabel,
    stock: p.stock,
  );
}
