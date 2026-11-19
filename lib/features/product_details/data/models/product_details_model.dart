import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/product_details.dart';

/// Parses the API's product JSON into the domain [ProductDetails].
abstract final class ProductDetailsModel {
  static ProductDetails fromJson(
    Map<String, dynamic> json,
    String languageCode,
  ) {
    final price = JsonReader.decimal(json['price']);
    // `final_price` is what the customer pays; a final price above the list
    // price is bad data.
    final paid =
        JsonReader.decimalOrNull(json['final_price']) ??
        JsonReader.decimalOrNull(json['discount_price']) ??
        price;
    final category = JsonReader.map(json['category']);
    return ProductDetails(
      id: JsonReader.integer(json['id']),
      name: JsonReader.translated(json, 'name', languageCode),
      categoryId: JsonReader.integer(json['category_id'] ?? category['id']),
      categoryName: JsonReader.translated(category, 'name', languageCode),
      price: price < 0 ? 0 : price,
      finalPrice: paid < 0 || paid > price ? price : paid,
      description: JsonReader.translated(json, 'description', languageCode),
      images: [
        for (final image in JsonReader.mapList(json['images']))
          ?JsonReader.stringOrNull(image['image_url']),
      ],
      viewersNow: JsonReader.integer(json['viewers_now']),
      stock: JsonReader.integer(json['number']),
      isActive: JsonReader.boolean(json['is_active'], true),
    );
  }
}
