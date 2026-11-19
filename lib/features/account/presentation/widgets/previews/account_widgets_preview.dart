import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../../core/widgets/app_menu_row.dart';
import '../../../../../core/widgets/previews/preview_wrapper.dart';
import '../../../../payment_cards/domain/entities/payment_card.dart';
import '../../../../payment_cards/presentation/widgets/payment_card_view.dart';
import '../../../../profile/presentation/pages/personal_info_page.dart';

// Run with:  flutter widget-preview start

Widget _menu(String a, String b, String c) => Column(
  children: [
    AppMenuRow(
      iconAsset: 'assets/icons/account/profile.svg',
      label: a,
      onTap: () {},
    ),
    AppMenuRow(
      iconAsset: 'assets/icons/account/addresses.svg',
      label: b,
      badge: 'Current',
      onTap: () {},
    ),
    AppMenuRow(
      iconAsset: 'assets/icons/account/share.svg',
      label: c,
      showChevron: false,
      showDivider: false,
      onTap: () {},
    ),
  ],
);

@Preview(
  group: 'Account / Menu rows',
  name: 'Rows (AR)',
  size: Size(375, 200),
  wrapper: rtlWrapper,
)
Widget menuArabic() =>
    _menu('المعلومات الشخصية', 'عناوين التوصيل', 'شارك التطبيق');

@Preview(
  group: 'Account / Menu rows',
  name: 'Rows (EN)',
  size: Size(375, 200),
  wrapper: ltrWrapper,
)
Widget menuEnglish() =>
    _menu('Personal information', 'Delivery addresses', 'Share the app');

@Preview(
  group: 'Account / Menu rows',
  name: 'Switch and subtitle',
  size: Size(375, 90),
  wrapper: rtlWrapper,
)
Widget menuSwitch() => AppMenuRow(
  leading: const Icon(Icons.notifications_none),
  label: 'إعدادات الإشعارات',
  subtitle: 'مفعّلة',
  showChevron: false,
  trailing: Switch(value: true, onChanged: (_) {}),
);

@Preview(
  group: 'Account / Personal information',
  name: 'Rows (AR)',
  size: Size(375, 330),
  wrapper: rtlWrapper,
)
Widget infoArabic() => const Column(
  children: [
    InfoRow(
      icon: 'assets/icons/account/name.svg',
      label: 'الاسم الكامل',
      value: 'أحمد محمد',
    ),
    InfoRow(
      icon: 'assets/icons/account/email.svg',
      label: 'البريد الإلكتروني',
      value: 'ahmad@example.com',
      ltrValue: true,
    ),
    InfoRow(
      icon: 'assets/icons/account/gender.svg',
      label: 'النوع الاجتماعي',
      value: 'غير محدد',
      muted: true,
    ),
    InfoRow(
      icon: 'assets/icons/account/phone.svg',
      label: 'رقم الجوال',
      value: '+962791234567',
      ltrValue: true,
      showDivider: false,
    ),
  ],
);

@Preview(
  group: 'Account / Payment card',
  name: 'Visa with a nickname (AR)',
  size: Size(375, 230),
  wrapper: rtlWrapper,
)
Widget cardVisa() => const PaymentCardView(
  brand: CardBrand.visa,
  last4: '4242',
  expiry: '12/30',
  expiresLabel: 'ينتهي في',
  nickname: 'بطاقة الراتب',
);

@Preview(
  group: 'Account / Payment card',
  name: 'Mastercard (EN)',
  size: Size(375, 230),
  wrapper: ltrWrapper,
)
Widget cardMastercard() => const PaymentCardView(
  brand: CardBrand.mastercard,
  last4: '4444',
  expiry: '01/31',
  expiresLabel: 'Expires',
);
