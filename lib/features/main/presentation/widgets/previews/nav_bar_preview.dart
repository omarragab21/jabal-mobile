import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../../core/widgets/previews/preview_wrapper.dart';
import '../../../domain/entities/main_tab.dart';
import '../app_bottom_nav_bar.dart';
import '../../../../../core/widgets/count_badge.dart';
import '../nav_bar_item.dart';

// Run with:  flutter widget-preview start

const _ar = ['الرئيسية', 'الأقسام', 'السلة', 'طلباتي', 'حسابي'];
const _en = ['Home', 'Categories', 'Cart', 'My orders', 'Account'];

Widget _bar(List<String> labels, int selected, int badge) => AppBottomNavBar(
  currentIndex: selected,
  onTap: (_) {},
  entries: [
    for (final tab in MainTab.values)
      NavBarEntry(
        label: labels[tab.index],
        iconAsset: tab.iconAsset,
        activeIconAsset: tab.activeIconAsset,
        badgeCount: tab == MainTab.cart ? badge : 0,
      ),
  ],
);

@Preview(
  group: 'Main / Nav bar',
  name: 'Home selected (AR)',
  size: Size(375, 110),
  wrapper: rtlWrapper,
)
Widget barHomeArabic() => _bar(_ar, 0, 120);

@Preview(
  group: 'Main / Nav bar',
  name: 'Orders selected (AR)',
  size: Size(375, 110),
  wrapper: rtlWrapper,
)
Widget barOrdersArabic() => _bar(_ar, 3, 120);

@Preview(
  group: 'Main / Nav bar',
  name: 'Account selected (EN)',
  size: Size(375, 110),
  wrapper: ltrWrapper,
)
Widget barAccountEnglish() => _bar(_en, 4, 7);

@Preview(group: 'Main / Nav bar', name: 'Item idle', wrapper: rtlWrapper)
Widget itemIdle() => SizedBox(
  width: 74,
  height: 70,
  child: NavBarItem(
    label: 'السلة',
    iconAsset: MainTab.cart.iconAsset,
    activeIconAsset: MainTab.cart.activeIconAsset,
    selected: false,
    badgeCount: 120,
    onTap: () {},
  ),
);

@Preview(group: 'Main / Badge', name: 'Counts', wrapper: rtlWrapper)
Widget badges() => const Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: [
    CountBadge(count: 3),
    CountBadge(count: 42),
    CountBadge(count: 99),
    CountBadge(count: 120),
  ],
);
