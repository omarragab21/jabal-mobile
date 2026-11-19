import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/orders_cubit.dart';

/// "Current orders" / "Previous orders" switch with a green underline.
class OrdersTabs extends StatelessWidget {
  const OrdersTabs({super.key, required this.selected, required this.onSelect});

  final OrdersTab selected;
  final ValueChanged<OrdersTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: Row(
        children: [
          for (final tab in OrdersTab.values)
            Expanded(
              child: _TabItem(
                label: 'orders.tab_${tab.name}'.tr(context: context),
                selected: tab == selected,
                onTap: () => onSelect(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 44.h,
            child: Center(
              child: Text(
                label,
                style:
                    (selected
                            ? AppTextStyles.textMdBold
                            : AppTextStyles.textMdRegular)
                        .copyWith(
                          color: selected
                              ? AppColors.textDefault
                              : AppColors.textLabel,
                        ),
              ),
            ),
          ),
          Container(
            height: 3.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
