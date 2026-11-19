import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/home_banner.dart';

/// [HomeBanner] parsed from `/v1/site/sliders`.
class HomeBannerModel extends HomeBanner {
  const HomeBannerModel({
    required super.id,
    required super.imageUrl,
    super.title,
    super.description,
    super.link,
    super.order,
  });

  factory HomeBannerModel.fromJson(
    Map<String, dynamic> json,
    String languageCode,
  ) => HomeBannerModel(
    id: JsonReader.integer(json['id']),
    imageUrl: JsonReader.string(json['image']),
    title: JsonReader.translated(json, 'title', languageCode),
    description: JsonReader.translated(json, 'description', languageCode),
    link: JsonReader.stringOrNull(json['link']),
    order: JsonReader.integer(json['order']),
  );

  /// A slide can only be shown when it is switched on and has a picture.
  static bool isVisible(Map<String, dynamic> json) =>
      JsonReader.boolean(json['status'], true) &&
      JsonReader.string(json['image']).isNotEmpty;
}
