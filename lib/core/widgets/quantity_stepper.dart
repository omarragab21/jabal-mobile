import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// "− 1 +" in a light grey box. A button that cannot be used any more (the
/// minimum of 1, or the stock) turns grey. [decrementIcon] swaps the minus
/// for another icon (a bin when one more step down removes the row).
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.decrementLabel,
    required this.incrementLabel,
    this.decrementIcon = Icons.remove,
    this.decrementAsset,
  });

  final int quantity;

  /// Null disables the button.
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final String decrementLabel;
  final String incrementLabel;
  final IconData decrementIcon;

  /// An SVG shown instead of [decrementIcon] (the bin icon).
  final String? decrementAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.buttonSecondary,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            key: const ValueKey('stepper-decrement'),
            icon: decrementIcon,
            asset: decrementAsset,
            label: decrementLabel,
            onTap: onDecrement,
          ),
          SizedBox(
            width: 28.w,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTextStyles.textLgBold.copyWith(
                color: AppColors.textDefault,
              ),
            ),
          ),
          _StepButton(
            key: const ValueKey('stepper-increment'),
            icon: Icons.add,
            label: incrementLabel,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    super.key,
    required this.icon,
    this.asset,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String? asset;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    label: label,
    child: InkResponse(
      onTap: onTap,
      radius: 22.r,
      child: SizedBox(
        width: 32.r,
        height: 40.h,
        child: Center(
          child: asset == null
              ? Icon(
                  icon,
                  size: 22.r,
                  color: onTap == null
                      ? AppColors.textDisabled
                      : AppColors.textDefault,
                )
              : SvgPicture.asset(
                  asset!,
                  width: 22.r,
                  height: 22.r,
                  colorFilter: ColorFilter.mode(
                    onTap == null
                        ? AppColors.textDisabled
                        : AppColors.textDefault,
                    BlendMode.srcIn,
                  ),
                ),
        ),
      ),
    ),
  );
}
