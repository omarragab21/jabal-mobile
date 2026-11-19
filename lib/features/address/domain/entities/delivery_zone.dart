import 'package:equatable/equatable.dart';

import 'geo_point.dart';

/// A circular area the store delivers to.
class DeliveryZone extends Equatable {
  const DeliveryZone({required this.center, required this.radiusKm})
    : assert(radiusKm > 0);

  final GeoPoint center;
  final double radiusKm;

  bool contains(GeoPoint point) => center.distanceKmTo(point) <= radiusKm;

  @override
  List<Object?> get props => [center, radiusKm];
}
