import '../../../../core/utils/result.dart';
import '../entities/address.dart';
import '../entities/delivery_location.dart';

/// The customer's saved addresses and which place they deliver to.
abstract interface class AddressRepository {
  Future<Result<List<Address>>> getAddresses();

  /// Adds the address, or replaces the one with the same id.
  Future<Result<void>> saveAddress(Address address);

  Future<Result<void>> deleteAddress(String id);

  Future<Result<DeliveryLocation?>> getDeliveryLocation();

  /// `null` clears the choice.
  Future<Result<void>> setDeliveryLocation(DeliveryLocation? location);
}
