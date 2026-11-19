import 'package:equatable/equatable.dart';

import 'address.dart';
import 'geo_point.dart';

/// Where the order will be delivered. Either one of the saved addresses or
/// a point that was only picked (map search, current location) and not saved.
class DeliveryLocation extends Equatable {
  const DeliveryLocation({
    required this.point,
    required this.label,
    required this.details,
    this.addressId,
  });

  DeliveryLocation.saved(Address address)
    : point = address.point,
      label = address.title,
      details = address.details,
      addressId = address.id;

  final GeoPoint point;

  /// Short text for the header: the address title, or the street for an
  /// unsaved point.
  final String label;
  final String details;

  /// Set when this is a saved address.
  final String? addressId;

  bool get isSaved => addressId != null;

  @override
  List<Object?> get props => [point, label, details, addressId];
}
