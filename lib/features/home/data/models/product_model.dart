import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/product.dart';

/// [Product] parsed from the catalogue API (`/v1/site/products/...`).
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.categoryId,
    required super.categoryName,
    required super.price,
    required super.finalPrice,
    super.imageUrl,
    super.attributes,
    super.stock,
    super.isActive,
    super.isFeatured,
  });

  factory ProductModel.fromJson(
    Map<String, dynamic> json,
    String languageCode,
  ) {
    final price = JsonReader.decimal(json['price']);
    // `final_price` is what the customer pays; older payloads only carry
    // `discount_price`. A final price above the list price is bad data.
    final paid =
        JsonReader.decimalOrNull(json['final_price']) ??
        JsonReader.decimalOrNull(json['discount_price']) ??
        price;
    final category = JsonReader.map(json['category']);
    final images = JsonReader.mapList(json['images']);
    return ProductModel(
      id: JsonReader.integer(json['id']),
      name: JsonReader.translated(json, 'name', languageCode),
      categoryId: JsonReader.integer(json['category_id'] ?? category['id']),
      categoryName: JsonReader.translated(category, 'name', languageCode),
      price: price < 0 ? 0 : price,
      finalPrice: paid < 0 || paid > price ? price : paid,
      imageUrl: images.isEmpty
          ? null
          : JsonReader.stringOrNull(
              images.first['thumb_url'] ?? images.first['image_url'],
            ),
      attributes: _attributes(json['attributes']),
      stock: JsonReader.integer(json['number']),
      isActive: JsonReader.boolean(json['is_active'], true),
      isFeatured: JsonReader.boolean(json['is_featured']),
    );
  }

  /// `{"الحجم": [{id, name, value_code}], ...}` — or `[]` when there are none.
  static List<ProductAttribute> _attributes(Object? raw) => [
    for (final entry in JsonReader.map(raw).entries)
      ProductAttribute(
        name: entry.key,
        values: [
          for (final value in JsonReader.mapList(entry.value))
            ProductAttributeValue(
              id: JsonReader.integer(value['id']),
              name: JsonReader.string(value['name']),
              colorHex: JsonReader.stringOrNull(value['value_code']),
            ),
        ],
      ),
  ];
}
