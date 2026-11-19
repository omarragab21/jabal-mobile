import '../../../../core/config/maps_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/place_info.dart';
import '../../domain/entities/place_suggestion.dart';
import 'places_remote_data_source.dart';

/// Google Places (autocomplete, details) and Geocoding web services.
class GooglePlacesRemoteDataSource implements PlacesRemoteDataSource {
  const GooglePlacesRemoteDataSource(
    this._client, {
    this.apiKey = MapsConfig.apiKey,
    this.countryCode = MapsConfig.countryCode,
    this.bias = const GeoPoint(
      MapsConfig.defaultLatitude,
      MapsConfig.defaultLongitude,
    ),
    this.biasRadiusMeters = 25000,
  });

  final ApiClient _client;
  final String apiKey;
  final String countryCode;
  final GeoPoint bias;
  final int biasRadiusMeters;

  /// Google answers 200 even for a denied key: the outcome is in `status`.
  Map<String, dynamic> _checked(Object? body) {
    final json = JsonReader.map(body);
    final status = JsonReader.string(json['status']);
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw ServerException(
        JsonReader.string(json['error_message'], status),
        statusCode: 200,
      );
    }
    return json;
  }

  @override
  Future<List<PlaceSuggestion>> autocomplete(
    String query,
    String languageCode,
  ) async {
    final json = _checked(
      await _client.get(
        '/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'components': 'country:$countryCode',
          'location': '${bias.latitude},${bias.longitude}',
          'radius': biasRadiusMeters,
          'language': languageCode,
          'key': apiKey,
        },
      ),
    );
    return [
      for (final item in JsonReader.mapList(json['predictions']))
        if (JsonReader.stringOrNull(item['place_id']) case final id?)
          PlaceSuggestion(
            placeId: id,
            description: JsonReader.string(item['description']),
          ),
    ];
  }

  @override
  Future<GeoPoint> placeLocation(String placeId) async {
    final json = _checked(
      await _client.get(
        '/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry',
          'key': apiKey,
        },
      ),
    );
    final location = JsonReader.map(
      JsonReader.map(JsonReader.map(json['result'])['geometry'])['location'],
    );
    final lat = JsonReader.decimalOrNull(location['lat']);
    final lng = JsonReader.decimalOrNull(location['lng']);
    if (lat == null || lng == null) throw const NotFoundException();
    return GeoPoint(lat, lng);
  }

  /// Plus codes (`8G5P+XX`) read badly as an address headline.
  static final RegExp _plusCode = RegExp(r'^[A-Z0-9]{4,8}\+[A-Z0-9]{2,}');

  @override
  Future<PlaceInfo?> reverseGeocode(GeoPoint point, String languageCode) async {
    final json = _checked(
      await _client.get(
        '/geocode/json',
        queryParameters: {
          'latlng': '${point.latitude},${point.longitude}',
          'language': languageCode,
          'key': apiKey,
        },
      ),
    );
    final addresses = [
      for (final result in JsonReader.mapList(json['results']))
        JsonReader.string(result['formatted_address']),
    ].where((text) => text.isNotEmpty).toList();
    if (addresses.isEmpty) return null;
    final readable = addresses.firstWhere(
      (text) => !_plusCode.hasMatch(text),
      orElse: () => addresses.first,
    );
    return PlaceInfo.fromFormatted(readable);
  }
}
