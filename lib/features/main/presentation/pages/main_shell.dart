import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/main_tab.dart';
import '../cubit/main_cubit.dart';
import '../cubit/main_state.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// The app's main screen: the selected tab's page above the bottom bar.
/// [pages] has one widget per [MainTab], in enum order. They live in an
/// [IndexedStack] so every tab keeps its state when you switch.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.pages}) : assert(pages.length == 5);

  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MainCubit>();
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) => Scaffold(
        backgroundColor: AppColors.white,
        body: IndexedStack(index: state.tab.index, children: pages),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: state.tab.index,
          onTap: (i) => cubit.select(MainTab.values[i]),
          entries: [
            for (final tab in MainTab.values)
              NavBarEntry(
                label: tab.labelKey.tr(context: context),
                iconAsset: tab.iconAsset,
                activeIconAsset: tab.activeIconAsset,
                badgeCount: tab == MainTab.cart ? state.cartCount : 0,
              ),
          ],
        ),
      ),
    );
  }
}
