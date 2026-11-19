import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/place_info.dart';
import '../../domain/entities/place_suggestion.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_remote_data_source.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  const PlacesRepositoryImpl(this._remote);

  final PlacesRemoteDataSource _remote;

  @override
  Future<Result<List<PlaceSuggestion>>> search(
    String query,
    String languageCode,
  ) => guard(() => _remote.autocomplete(query, languageCode));

  @override
  Future<Result<GeoPoint>> pointOf(PlaceSuggestion suggestion) =>
      guard(() => _remote.placeLocation(suggestion.placeId));

  @override
  Future<Result<PlaceInfo>> describe(GeoPoint point, String languageCode) =>
      guard(() async {
        final info = await _remote.reverseGeocode(point, languageCode);
        if (info == null) throw const NotFoundException();
        return info;
      });
}
