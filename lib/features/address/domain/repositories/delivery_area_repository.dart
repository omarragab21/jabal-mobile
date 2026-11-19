import '../entities/geo_point.dart';

/// Whether the store delivers to a place.
abstract interface class DeliveryAreaRepository {
  Future<bool> isDeliverable(GeoPoint point);
}
