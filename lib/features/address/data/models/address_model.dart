import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/address_type.dart';
import '../../domain/entities/delivery_location.dart';
import '../../domain/entities/geo_point.dart';

GeoPoint? _point(Map<String, dynamic> json) {
  final lat = JsonReader.decimalOrNull(json['lat']);
  final lng = JsonReader.decimalOrNull(json['lng']);
  if (lat == null || lng == null) return null;
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
  return GeoPoint(lat, lng);
}

/// [Address] as it is stored on the device.
abstract final class AddressModel {
  /// Null when the record is unusable (no id or no coordinates).
  static Address? tryFromJson(Map<String, dynamic> json) {
    final id = JsonReader.stringOrNull(json['id']);
    final point = _point(json);
    if (id == null || point == null) return null;
    return Address(
      id: id,
      title: JsonReader.string(json['title']),
      details: JsonReader.string(json['details']),
      point: point,
      type: AddressType.parse(JsonReader.stringOrNull(json['type'])),
      phone: JsonReader.string(json['phone']),
      building: JsonReader.string(json['building']),
      floor: JsonReader.string(json['floor']),
      unit: JsonReader.string(json['unit']),
      instructions: JsonReader.string(json['instructions']),
    );
  }

  static Map<String, dynamic> toJson(Address address) => {
    'id': address.id,
    'title': address.title,
    'details': address.details,
    'lat': address.point.latitude,
    'lng': address.point.longitude,
    'type': address.type.name,
    'phone': address.phone,
    'building': address.building,
    'floor': address.floor,
    'unit': address.unit,
    'instructions': address.instructions,
  };
}

/// [DeliveryLocation] as it is stored on the device.
abstract final class DeliveryLocationModel {
  static DeliveryLocation? tryFromJson(Map<String, dynamic> json) {
    final point = _point(json);
    if (point == null) return null;
    return DeliveryLocation(
      point: point,
      label: JsonReader.string(json['label']),
      details: JsonReader.string(json['details']),
      addressId: JsonReader.stringOrNull(json['addressId']),
    );
  }

  static Map<String, dynamic> toJson(DeliveryLocation location) => {
    'lat': location.point.latitude,
    'lng': location.point.longitude,
    'label': location.label,
    'details': location.details,
    'addressId': location.addressId,
  };
}
