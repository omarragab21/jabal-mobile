import '../../../../core/utils/result.dart';
import '../entities/address.dart';
import '../entities/delivery_location.dart';
import '../repositories/address_repository.dart';

class GetAddresses {
  const GetAddresses(this._repository);
  final AddressRepository _repository;

  Future<Result<List<Address>>> call() => _repository.getAddresses();
}

class SaveAddress {
  const SaveAddress(this._repository);
  final AddressRepository _repository;

  Future<Result<void>> call(Address address) =>
      _repository.saveAddress(address);
}

class DeleteAddress {
  const DeleteAddress(this._repository);
  final AddressRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteAddress(id);
}

class GetDeliveryLocation {
  const GetDeliveryLocation(this._repository);
  final AddressRepository _repository;

  Future<Result<DeliveryLocation?>> call() => _repository.getDeliveryLocation();
}

class SetDeliveryLocation {
  const SetDeliveryLocation(this._repository);
  final AddressRepository _repository;

  Future<Result<void>> call(DeliveryLocation? location) =>
      _repository.setDeliveryLocation(location);
}
