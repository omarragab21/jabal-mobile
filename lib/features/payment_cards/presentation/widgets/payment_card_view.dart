import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/payment_card.dart';

/// The face of a card: brand, `•••• 1234`, the expiry and the nickname.
class PaymentCardView extends StatelessWidget {
  const PaymentCardView({
    super.key,
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.expiresLabel,
    this.nickname = '',
  });

  final CardBrand brand;
  final String last4;
  final String expiry;

  /// `ينتهي في`
  final String expiresLabel;
  final String nickname;

  static String brandName(CardBrand brand) => switch (brand) {
    CardBrand.visa => 'VISA',
    CardBrand.mastercard => 'MASTERCARD',
    CardBrand.other => 'CARD',
  };

  @override
  Widget build(BuildContext context) {
    final white = AppTextStyles.textMdRegular.copyWith(color: AppColors.white);
    return AspectRatio(
      aspectRatio: 343 / 190,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [AppColors.textDisplay, AppColors.primary],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.textMdBold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                Text(
                  brandName(brand),
                  style: AppTextStyles.textMdBold.copyWith(
                    color: AppColors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '••••  ••••  ••••  $last4',
              textDirection: TextDirection.ltr,
              style: AppTextStyles.textLgBold.copyWith(
                color: AppColors.white,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 12.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$expiresLabel  '),
                  TextSpan(
                    text: expiry,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              style: white,
            ),
          ],
        ),
      ),
    );
  }
}
