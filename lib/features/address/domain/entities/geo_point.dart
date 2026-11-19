import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// A place on Earth, without depending on any map SDK.
class GeoPoint extends Equatable {
  const GeoPoint(this.latitude, this.longitude)
    : assert(latitude >= -90 && latitude <= 90),
      assert(longitude >= -180 && longitude <= 180);

  final double latitude;
  final double longitude;

  /// Great-circle distance to [other] in kilometres (haversine).
  double distanceKmTo(GeoPoint other) {
    const earthRadiusKm = 6371.0088;
    double rad(double deg) => deg * math.pi / 180;
    final dLat = rad(other.latitude - latitude);
    final dLng = rad(other.longitude - longitude);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(latitude)) *
            math.cos(rad(other.latitude)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * earthRadiusKm * math.asin(math.sqrt(a));
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
