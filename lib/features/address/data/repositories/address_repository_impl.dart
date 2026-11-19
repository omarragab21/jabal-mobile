import '../../../../core/utils/result.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/delivery_location.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_local_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  const AddressRepositoryImpl(this._local);

  final AddressLocalDataSource _local;

  @override
  Future<Result<List<Address>>> getAddresses() =>
      guard(() async => _local.readAddresses());

  @override
  Future<Result<void>> saveAddress(Address address) => guard(() async {
    final addresses = _local.readAddresses();
    final index = addresses.indexWhere((a) => a.id == address.id);
    if (index < 0) {
      addresses.add(address);
    } else {
      addresses[index] = address;
    }
    await _local.writeAddresses(addresses);
    // An edited address that is the delivery place keeps the header in sync.
    final current = _local.readDeliveryLocation();
    if (current?.addressId == address.id) {
      await _local.writeDeliveryLocation(DeliveryLocation.saved(address));
    }
  });

  @override
  Future<Result<void>> deleteAddress(String id) => guard(() async {
    await _local.writeAddresses([
      for (final a in _local.readAddresses())
        if (a.id != id) a,
    ]);
    if (_local.readDeliveryLocation()?.addressId == id) {
      await _local.writeDeliveryLocation(null);
    }
  });

  @override
  Future<Result<DeliveryLocation?>> getDeliveryLocation() =>
      guard(() async => _local.readDeliveryLocation());

  @override
  Future<Result<void>> setDeliveryLocation(DeliveryLocation? location) =>
      guard(() => _local.writeDeliveryLocation(location));
}
