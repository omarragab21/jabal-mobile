import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/checkout_cubit.dart';

/// The discount code box: the field with its "apply" tab at the end, and a
/// line under it saying whether the code worked.
class PromoCodeContent extends StatefulWidget {
  const PromoCodeContent({
    super.key,
    required this.state,
    required this.onChanged,
    required this.onApply,
  });

  final CheckoutState state;
  final ValueChanged<String> onChanged;
  final VoidCallback onApply;

  @override
  State<PromoCodeContent> createState() => _PromoCodeContentState();
}

class _PromoCodeContentState extends State<PromoCodeContent> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'checkout.$key'.tr(context: context);
    final state = widget.state;
    final invalid = state.promoStatus == PromoStatus.invalid;
    final applied = state.promoStatus == PromoStatus.applied;
    final borderColor = invalid ? AppColors.error : AppColors.border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48.h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('promo-field'),
                  controller: _controller,
                  onChanged: widget.onChanged,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => widget.onApply(),
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.textDefault,
                  ),
                  decoration: InputDecoration(
                    hintText: t('promo_hint'),
                    hintStyle: AppTextStyles.textMdRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                ),
              ),
              InkWell(
                key: const ValueKey('promo-apply'),
                onTap: state.canApplyPromo ? widget.onApply : null,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  height: double.infinity,
                  color: state.canApplyPromo || applied
                      ? AppColors.primary
                      : AppColors.buttonSecondary,
                  child: state.promoStatus == PromoStatus.applying
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          t('apply'),
                          style: AppTextStyles.textMdRegular.copyWith(
                            color: state.canApplyPromo || applied
                                ? AppColors.white
                                : AppColors.textLabel,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        if (applied || invalid) ...[
          SizedBox(height: 8.h),
          Text(
            applied ? t('promo_applied') : t('promo_invalid'),
            key: ValueKey(applied ? 'promo-applied' : 'promo-invalid'),
            style: AppTextStyles.textSmRegular.copyWith(
              color: applied ? const Color(0xFF219F21) : AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
