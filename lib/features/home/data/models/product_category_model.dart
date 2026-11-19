import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/product_category.dart';

/// [ProductCategory] parsed from `/v1/site/categories`.
class ProductCategoryModel extends ProductCategory {
  const ProductCategoryModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.parentId,
    super.sortOrder,
    super.subCategories,
  });

  factory ProductCategoryModel.fromJson(
    Map<String, dynamic> json,
    String languageCode,
  ) => ProductCategoryModel(
    id: JsonReader.integer(json['id']),
    name: JsonReader.translated(json, 'name', languageCode),
    imageUrl: JsonReader.stringOrNull(json['image_url']),
    parentId: json['parent_id'] == null
        ? null
        : JsonReader.integer(json['parent_id']),
    sortOrder: JsonReader.integer(json['sort_order']),
    subCategories: _children(json, languageCode),
  );

  /// `sub_categories` as nested categories, ordered by `sort_order`. Inactive
  /// children are left out.
  static List<ProductCategoryModel> _children(
    Map<String, dynamic> json,
    String languageCode,
  ) {
    final children = [
      for (final child in JsonReader.mapList(json['sub_categories']))
        if (JsonReader.boolean(child['is_active'], true))
          ProductCategoryModel.fromJson(child, languageCode),
    ];
    return children..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
