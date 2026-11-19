import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/entities/address_type.dart';

/// The icon of an [AddressType] (building, villa, office, pin).
class AddressTypeIcon extends StatelessWidget {
  const AddressTypeIcon(this.type, {super.key});

  final AddressType type;

  static String assetOf(AddressType type) => switch (type) {
    AddressType.apartment => 'assets/icons/address/type_apartment.svg',
    AddressType.house => 'assets/icons/address/type_house.svg',
    AddressType.office => 'assets/icons/address/type_office.svg',
    AddressType.other => 'assets/icons/address/type_other.svg',
  };

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset(assetOf(type), width: 24.r, height: 24.r);
}
