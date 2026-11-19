import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/address.dart';
import 'address_type_icon.dart';
import 'sheet_frame.dart';

/// "عناوين التوصيل": the saved addresses, tap one to deliver there.
class AddressListSheet extends StatelessWidget {
  const AddressListSheet({
    super.key,
    required this.addresses,
    required this.onSelected,
    required this.onAddNew,
  });

  final List<Address> addresses;
  final ValueChanged<Address> onSelected;
  final VoidCallback onAddNew;

  /// `32, سهيل بن عمرو, طبربور, 079XXXXXXX`
  static String subtitleOf(Address address) => [
    address.details,
    address.phone,
  ].where((part) => part.isNotEmpty).join(', ');

  @override
  Widget build(BuildContext context) {
    return SheetFrame(
      title: 'address.delivery_addresses'.tr(context: context),
      buttonLabel: 'address.add_new_address'.tr(context: context),
      onButton: onAddNew,
      children: [
        for (var i = 0; i < addresses.length; i++) ...[
          if (i > 0) const SheetDivider(),
          SheetRow(
            key: ValueKey('address-${addresses[i].id}'),
            leading: AddressTypeIcon(addresses[i].type),
            title: addresses[i].title,
            subtitle: subtitleOf(addresses[i]),
            onTap: () => onSelected(addresses[i]),
          ),
        ],
      ],
    );
  }
}
