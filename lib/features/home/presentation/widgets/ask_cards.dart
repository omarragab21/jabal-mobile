import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One coloured shortcut card: an icon above a white title.
class AskCard extends StatelessWidget {
  const AskCard({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.color,
    this.onTap,
  });

  final String label;
  final String iconAsset;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 110.h),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(iconAsset, width: 32.r, height: 32.r),
              SizedBox(height: 8.h),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.textMdBold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The two "ask" shortcuts side by side; the pharmacist comes first.
class AskCardsRow extends StatelessWidget {
  const AskCardsRow({
    super.key,
    required this.pharmacistLabel,
    required this.beauticianLabel,
    this.onPharmacist,
    this.onBeautician,
  });

  final String pharmacistLabel;
  final String beauticianLabel;
  final VoidCallback? onPharmacist;
  final VoidCallback? onBeautician;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AskCard(
              label: pharmacistLabel,
              iconAsset: 'assets/icons/home/ask_pharmacist.svg',
              color: AppColors.primary,
              onTap: onPharmacist,
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: AskCard(
              label: beauticianLabel,
              iconAsset: 'assets/icons/home/ask_beautician.svg',
              color: AppColors.teal,
              onTap: onBeautician,
            ),
          ),
        ],
      ),
    );
  }
}
