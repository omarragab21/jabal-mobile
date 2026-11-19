import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/delivery_location.dart';
import '../models/address_model.dart';

/// Where saved addresses and the delivery choice live.
abstract interface class AddressLocalDataSource {
  List<Address> readAddresses();
  Future<void> writeAddresses(List<Address> addresses);
  DeliveryLocation? readDeliveryLocation();
  Future<void> writeDeliveryLocation(DeliveryLocation? location);
}

/// Keeps them as JSON in [LocalStorage]. Unreadable data is ignored, not
/// thrown: a corrupted value must not stop the app from starting.
class StorageAddressLocalDataSource implements AddressLocalDataSource {
  const StorageAddressLocalDataSource(this._storage);

  final LocalStorage _storage;

  Object? _decode(String? raw) {
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  @override
  List<Address> readAddresses() => [
    for (final item in JsonReader.mapList(
      _decode(_storage.getString(StorageKeys.addresses)),
    ))
      ?AddressModel.tryFromJson(item),
  ];

  @override
  Future<void> writeAddresses(List<Address> addresses) => _storage.setString(
    StorageKeys.addresses,
    jsonEncode([for (final a in addresses) AddressModel.toJson(a)]),
  );

  @override
  DeliveryLocation? readDeliveryLocation() {
    final json = JsonReader.map(
      _decode(_storage.getString(StorageKeys.deliverySelection)),
    );
    return json.isEmpty ? null : DeliveryLocationModel.tryFromJson(json);
  }

  @override
  Future<void> writeDeliveryLocation(DeliveryLocation? location) =>
      location == null
      ? _storage.remove(StorageKeys.deliverySelection)
      : _storage.setString(
          StorageKeys.deliverySelection,
          jsonEncode(DeliveryLocationModel.toJson(location)),
        );
}
