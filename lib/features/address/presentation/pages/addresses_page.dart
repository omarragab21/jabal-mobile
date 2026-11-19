import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_menu_row.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../domain/entities/address.dart';
import '../cubit/delivery_location_cubit.dart';
import '../cubit/delivery_location_state.dart';
import '../widgets/address_list_sheet.dart';
import '../widgets/address_type_icon.dart';

/// "عناوين التوصيل": every saved address; tap one to edit it.
class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key, required this.onAdd, required this.onEdit});

  final VoidCallback onAdd;
  final ValueChanged<Address> onEdit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryLocationCubit, DeliveryLocationState>(
      builder: (context, state) => AppSubPage(
        title: 'address.delivery_addresses'.tr(context: context),
        body: state.addresses.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    'address.no_addresses'.tr(context: context),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.textMdRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            : ListView(
                children: [
                  for (final address in state.addresses)
                    _AddressRow(
                      key: ValueKey('address-${address.id}'),
                      address: address,
                      selected: state.selection?.addressId == address.id,
                      onTap: () => onEdit(address),
                    ),
                ],
              ),
        bottom: AppButton(
          label: 'address.add_new_address'.tr(context: context),
          onPressed: onAdd,
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    super.key,
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final Address address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppMenuRow(
    label: address.title,
    subtitle: AddressListSheet.subtitleOf(address),
    badge: selected ? 'address.current'.tr(context: context) : null,
    leading: AddressTypeIcon(address.type),
    onTap: onTap,
  );
}
