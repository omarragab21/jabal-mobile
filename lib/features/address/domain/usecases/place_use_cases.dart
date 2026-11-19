import '../../../../core/utils/result.dart';
import '../entities/geo_point.dart';
import '../entities/place_info.dart';
import '../entities/place_suggestion.dart';
import '../repositories/delivery_area_repository.dart';
import '../repositories/location_repository.dart';
import '../repositories/places_repository.dart';

class SearchPlaces {
  const SearchPlaces(this._repository);
  final PlacesRepository _repository;

  /// Shortest text worth searching for.
  static const int minLength = 2;

  Future<Result<List<PlaceSuggestion>>> call(
    String query,
    String languageCode,
  ) {
    final text = query.trim();
    if (text.length < minLength) return Future.value(const Success([]));
    return _repository.search(text, languageCode);
  }
}

class GetPlacePoint {
  const GetPlacePoint(this._repository);
  final PlacesRepository _repository;

  Future<Result<GeoPoint>> call(PlaceSuggestion suggestion) =>
      _repository.pointOf(suggestion);
}

class DescribePlace {
  const DescribePlace(this._repository);
  final PlacesRepository _repository;

  Future<Result<PlaceInfo>> call(GeoPoint point, String languageCode) =>
      _repository.describe(point, languageCode);
}

class GetCurrentLocation {
  const GetCurrentLocation(this._repository);
  final LocationRepository _repository;

  Future<Result<GeoPoint>> call() => _repository.currentPoint();
}

class CheckDeliveryArea {
  const CheckDeliveryArea(this._repository);
  final DeliveryAreaRepository _repository;

  Future<bool> call(GeoPoint point) => _repository.isDeliverable(point);
}
