import '../../domain/entities/geo_point.dart';
import '../../domain/entities/place_info.dart';
import '../../domain/entities/place_suggestion.dart';
import 'places_remote_data_source.dart';

/// A place the mock knows, with both language names.
class MockPlace {
  const MockPlace(this.id, this.point, this.ar, this.en);

  final String id;
  final GeoPoint point;
  final PlaceInfo ar;
  final PlaceInfo en;
}

/// Offline places for tests and demos: a few streets in Jordan.
class MockPlacesRemoteDataSource implements PlacesRemoteDataSource {
  const MockPlacesRemoteDataSource({
    this.latency = const Duration(milliseconds: 300),
  });

  final Duration latency;

  static const List<MockPlace> places = [
    MockPlace(
      'tabarbour',
      GeoPoint(31.9863, 35.9814),
      PlaceInfo(headline: 'سهيل بن عمرو', details: 'طبربور، عمّان'),
      PlaceInfo(headline: 'Suhail Bin Amr St', details: 'Tabarbour, Amman'),
    ),
    MockPlace(
      'jabal-hussein',
      GeoPoint(31.9632, 35.9189),
      PlaceInfo(headline: 'مجمع البواب', details: 'جبل الحسين، عمّان'),
      PlaceInfo(
        headline: 'Al-Bawwab Complex',
        details: 'Jabal Al-Hussein, Amman',
      ),
    ),
    MockPlace(
      'abdali',
      GeoPoint(31.9645, 35.9060),
      PlaceInfo(headline: 'شارع الملك حسين', details: 'العبدلي، عمّان'),
      PlaceInfo(headline: 'King Hussein St', details: 'Abdali, Amman'),
    ),
    MockPlace(
      'irbid',
      GeoPoint(32.5556, 35.8469),
      PlaceInfo(headline: 'شارع الدفاع', details: 'إربد، مدينة الحسن للشباب'),
      PlaceInfo(
        headline: 'Al-Difaa St',
        details: 'Irbid, Al-Hassan Youth City',
      ),
    ),
    MockPlace(
      'aqaba',
      GeoPoint(29.5321, 35.0063),
      PlaceInfo(headline: 'شارع الكورنيش', details: 'العقبة'),
      PlaceInfo(headline: 'Corniche St', details: 'Aqaba'),
    ),
  ];

  Future<void> _delay() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }

  PlaceInfo _name(MockPlace place, String languageCode) =>
      languageCode == 'ar' ? place.ar : place.en;

  @override
  Future<List<PlaceSuggestion>> autocomplete(
    String query,
    String languageCode,
  ) async {
    await _delay();
    final text = query.toLowerCase();
    return [
      for (final place in places)
        if (place.ar.fullText.contains(text) ||
            place.en.fullText.toLowerCase().contains(text))
          PlaceSuggestion(
            placeId: place.id,
            description: _name(place, languageCode).fullText,
          ),
    ];
  }

  @override
  Future<GeoPoint> placeLocation(String placeId) async {
    await _delay();
    return places.firstWhere((place) => place.id == placeId).point;
  }

  /// The nearest known place, whatever the distance.
  @override
  Future<PlaceInfo?> reverseGeocode(GeoPoint point, String languageCode) async {
    await _delay();
    final nearest = [...places]
      ..sort(
        (a, b) =>
            a.point.distanceKmTo(point).compareTo(b.point.distanceKmTo(point)),
      );
    return _name(nearest.first, languageCode);
  }
}
