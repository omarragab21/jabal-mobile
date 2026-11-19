import '../../../../core/utils/result.dart';
import '../entities/geo_point.dart';
import '../entities/place_info.dart';
import '../entities/place_suggestion.dart';

/// Place search and geocoding. [languageCode] (`ar` / `en`) picks the
/// language of the returned texts.
abstract interface class PlacesRepository {
  Future<Result<List<PlaceSuggestion>>> search(
    String query,
    String languageCode,
  );

  Future<Result<GeoPoint>> pointOf(PlaceSuggestion suggestion);

  Future<Result<PlaceInfo>> describe(GeoPoint point, String languageCode);
}
