import '../../domain/entities/delivery_zone.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/repositories/delivery_area_repository.dart';

/// Delivers to the places inside any of its [zones].
///
/// Until the backend publishes the delivery areas this is a fixed policy:
/// [greaterAmman].
class ServiceAreaDeliveryRepository implements DeliveryAreaRepository {
  const ServiceAreaDeliveryRepository({this.zones = const [greaterAmman]});

  final List<DeliveryZone> zones;

  /// Amman and its surroundings (40 km).
  static const DeliveryZone greaterAmman = DeliveryZone(
    center: GeoPoint(31.9539, 35.9106),
    radiusKm: 40,
  );

  @override
  Future<bool> isDeliverable(GeoPoint point) async =>
      zones.any((zone) => zone.contains(point));
}
