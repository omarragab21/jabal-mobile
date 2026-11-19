import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// Nothing matched: a crossed magnifier, what to try, and a button to ask the
/// pharmacist.
class SearchNoResultsView extends StatelessWidget {
  const SearchNoResultsView({super.key, required this.onAskPharmacist});

  final VoidCallback onAskPharmacist;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/search_empty.svg',
              width: 56.r,
              height: 56.r,
            ),
            SizedBox(height: 24.h),
            Text(
              'search.no_results_title'.tr(context: context),
              textAlign: TextAlign.center,
              style: AppTextStyles.displayXsBold.copyWith(
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'search.no_results_message'.tr(context: context),
              textAlign: TextAlign.center,
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.textDefault,
              ),
            ),
            SizedBox(height: 24.h),
            AppButton(
              key: const ValueKey('search-ask-pharmacist'),
              label: 'home.ask_pharmacist'.tr(context: context),
              onPressed: onAskPharmacist,
            ),
          ],
        ),
      ),
    );
  }
}
