import '../../domain/entities/geo_point.dart';
import '../../domain/entities/place_info.dart';
import '../../domain/entities/place_suggestion.dart';

/// Where place search and geocoding come from. Every call throws an
/// `AppException` on failure.
abstract interface class PlacesRemoteDataSource {
  Future<List<PlaceSuggestion>> autocomplete(String query, String languageCode);

  Future<GeoPoint> placeLocation(String placeId);

  /// The text for [point]; `null` when the geocoder knows nothing there.
  Future<PlaceInfo?> reverseGeocode(GeoPoint point, String languageCode);
}
