/// Google Maps Platform settings.
///
/// The native Maps SDK reads its key from `AndroidManifest.xml` and
/// `AppDelegate.swift`; the Places / Geocoding REST calls made from Dart use
/// the same key. Override it per build without touching the code:
/// `flutter run --dart-define=GOOGLE_MAPS_API_KEY=...`
abstract final class MapsConfig {
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyDYX66jzMXfTvnHtCq9l90Eogq1k8nmVTQ',
  );

  static const String placesBaseUrl = 'https://maps.googleapis.com/maps/api';

  /// Search results are limited to this country (ISO 3166-1 alpha-2).
  static const String countryCode = 'jo';

  /// Where the map opens when nothing else is known: Amman.
  static const double defaultLatitude = 31.9539;
  static const double defaultLongitude = 35.9106;
  static const double defaultZoom = 15;
}
