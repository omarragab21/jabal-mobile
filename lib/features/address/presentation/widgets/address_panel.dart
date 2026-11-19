import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/place_info.dart';
import '../cubit/map_picker_state.dart';

/// Bottom panel of the map page: the address of the pin and the confirm
/// button (grey until the place can be confirmed).
class AddressPanel extends StatelessWidget {
  const AddressPanel({
    super.key,
    required this.status,
    required this.place,
    required this.failedText,
    required this.confirmLabel,
    required this.onConfirm,
  });

  final PlaceStatus status;
  final PlaceInfo? place;

  /// Shown when the address of the pin could not be found.
  final String failedText;
  final String confirmLabel;

  /// Null disables the button.
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final place = this.place;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                constraints: BoxConstraints(minHeight: 67.h),
                padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 16.w, 12.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/address/pin_card.svg',
                        width: 24.r,
                        height: 24.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(child: _text(place)),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              AppButton(
                label: confirmLabel,
                onPressed: onConfirm,
                greyWhenDisabled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _text(PlaceInfo? place) {
    if (status == PlaceStatus.loading) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: 20.r,
          height: 20.r,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }
    if (place == null) {
      return Text(
        failedText,
        style: AppTextStyles.textMdRegular.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          place.headline,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.textMdBold.copyWith(
            color: AppColors.textDefault,
          ),
        ),
        if (place.details.isNotEmpty)
          Text(
            place.details,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.textLabel,
            ),
          ),
      ],
    );
  }
}
