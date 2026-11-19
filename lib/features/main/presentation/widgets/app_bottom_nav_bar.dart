import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import 'nav_bar_item.dart';

/// Data for one bar entry (already translated, so the bar itself is free of
/// localization and easy to preview).
class NavBarEntry {
  const NavBarEntry({
    required this.label,
    required this.iconAsset,
    required this.activeIconAsset,
    this.badgeCount = 0,
  });

  final String label;
  final String iconAsset;
  final String activeIconAsset;
  final int badgeCount;
}

/// The 70pt tab bar with a 1pt top border. The bottom safe area (home
/// indicator) is added below it. Items follow the text direction.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.entries,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavBarEntry> entries;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.neutral200)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                for (var i = 0; i < entries.length; i++)
                  Expanded(
                    child: NavBarItem(
                      label: entries[i].label,
                      iconAsset: entries[i].iconAsset,
                      activeIconAsset: entries[i].activeIconAsset,
                      badgeCount: entries[i].badgeCount,
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
