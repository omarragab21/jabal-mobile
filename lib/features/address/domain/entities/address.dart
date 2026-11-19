import 'package:equatable/equatable.dart';

import 'address_type.dart';
import 'geo_point.dart';

/// A delivery address the customer saved.
class Address extends Equatable {
  const Address({
    required this.id,
    required this.title,
    required this.details,
    required this.point,
    this.type = AddressType.other,
    this.phone = '',
    this.building = '',
    this.floor = '',
    this.unit = '',
    this.instructions = '',
  });

  final String id;

  /// What the customer calls it: "My Home", "المكتب".
  final String title;

  /// Street and area: "32, سهيل بن عمرو, طبربور".
  final String details;
  final GeoPoint point;
  final AddressType type;
  final String phone;

  /// Where exactly, by type: the building name (apartment, office) or a
  /// description of the place (other).
  final String building;
  final String floor;

  /// The house, apartment or office number.
  final String unit;

  /// Notes for the courier.
  final String instructions;

  Address copyWith({
    String? title,
    String? details,
    GeoPoint? point,
    AddressType? type,
    String? phone,
    String? building,
    String? floor,
    String? unit,
    String? instructions,
  }) => Address(
    id: id,
    title: title ?? this.title,
    details: details ?? this.details,
    point: point ?? this.point,
    type: type ?? this.type,
    phone: phone ?? this.phone,
    building: building ?? this.building,
    floor: floor ?? this.floor,
    unit: unit ?? this.unit,
    instructions: instructions ?? this.instructions,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    details,
    point,
    type,
    phone,
    building,
    floor,
    unit,
    instructions,
  ];
}
