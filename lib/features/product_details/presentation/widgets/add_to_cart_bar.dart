import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/quantity_stepper.dart';

/// Bottom bar of the product page: the quantity stepper above a wide green
/// button with its [label] at the start and the [total] at the end.
class AddToCartBar extends StatelessWidget {
  const AddToCartBar({
    super.key,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.decrementLabel,
    required this.incrementLabel,
    required this.label,
    required this.total,
    required this.onPressed,
  });

  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final String decrementLabel;
  final String incrementLabel;
  final String label;

  /// Price text of the chosen quantity; null hides it (out of stock).
  final String? total;

  /// Null disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Above the button, at the end edge (the left in Arabic).
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: QuantityStepper(
                  quantity: quantity,
                  onDecrement: onDecrement,
                  onIncrement: onIncrement,
                  decrementLabel: decrementLabel,
                  incrementLabel: incrementLabel,
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 44.h,
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnColorPrimary,
                    disabledBackgroundColor: AppColors.neutral200,
                    disabledForegroundColor: AppColors.textDisabled,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    textStyle: AppTextStyles.textMdRegular,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(label)),
                      if (total != null) Text(total!),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
