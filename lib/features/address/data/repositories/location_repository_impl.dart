import '../../../../core/utils/result.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/device_location_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._device);

  final DeviceLocationDataSource _device;

  @override
  Future<Result<GeoPoint>> currentPoint() => guard(_device.currentPoint);
}
