import 'package:geolocator/geolocator.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/geo_point.dart';

/// Reads the device position.
abstract interface class DeviceLocationDataSource {
  /// Throws `LocationDisabledException` / `LocationPermissionException`.
  Future<GeoPoint> currentPoint();
}

/// `geolocator` implementation.
class GeolocatorDeviceLocation implements DeviceLocationDataSource {
  const GeolocatorDeviceLocation();

  @override
  Future<GeoPoint> currentPoint() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationDisabledException();
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException();
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return GeoPoint(position.latitude, position.longitude);
  }
}
