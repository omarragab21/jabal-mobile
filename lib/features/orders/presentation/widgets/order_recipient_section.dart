import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/order.dart';
import 'order_info_rows.dart';

/// Who gets the gift and where it goes.
class OrderRecipientContent extends StatelessWidget {
  const OrderRecipientContent({super.key, required this.recipient});

  final OrderRecipient recipient;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledValue(
          label: 'orders.recipient.gift_recipient'.tr(context: context),
          value: recipient.name,
        ),
        const InfoDivider(),
        LabeledValue(
          label: 'orders.recipient.address'.tr(context: context),
          value: recipient.address,
        ),
      ],
    );
  }
}
