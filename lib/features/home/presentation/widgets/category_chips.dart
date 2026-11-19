import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Sideways row of sub-category chips that filter the page. The first chip,
/// [allLabel], shows everything; the selected chip is green.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.allLabel,
    required this.labels,
    this.selectedIndex = 0,
    this.onSelected,
  });

  final String allLabel;
  final List<String> labels;

  /// 0 is the "all" chip, `i + 1` is `labels[i]`.
  final int selectedIndex;

  /// The chip at this position was tapped (same numbering as
  /// [selectedIndex]).
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: labels.length + 1,
        separatorBuilder: (_, _) => SizedBox(width: 9.w),
        itemBuilder: (_, index) => _Chip(
          label: index == 0 ? allLabel : labels[index - 1],
          selected: index == selectedIndex,
          onTap: onSelected == null ? null : () => onSelected!(index),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(4.r);
    return Semantics(
      button: !selected,
      selected: selected,
      child: Material(
        color: selected ? AppColors.primary : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: selected
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: selected ? null : onTap,
          borderRadius: radius,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              label,
              maxLines: 1,
              style: AppTextStyles.textSmRegular.copyWith(
                color: selected ? AppColors.white : AppColors.textDefault,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
