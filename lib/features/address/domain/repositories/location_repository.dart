import '../../../../core/utils/result.dart';
import '../entities/geo_point.dart';

/// The device location.
abstract interface class LocationRepository {
  /// Asks for permission if needed and reads the position. Fails with a
  /// `LocationPermissionFailure` or `LocationDisabledFailure`.
  Future<Result<GeoPoint>> currentPoint();
}
