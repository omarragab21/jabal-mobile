import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../formatters/orders_formatters.dart';
import 'order_info_rows.dart';

/// Card shown while no courier is assigned yet.
class SearchingCourierCard extends StatelessWidget {
  const SearchingCourierCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'orders.delivery.searching'.tr(context: context),
            style: AppTextStyles.textMdRegular.copyWith(
              color: AppColors.textDefault,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'orders.delivery.searching_hint'.tr(context: context),
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The courier, how to reach them, when they arrive and the code to share.
class OrderDeliveryContent extends StatelessWidget {
  const OrderDeliveryContent({
    super.key,
    required this.order,
    required this.onCall,
    required this.onWhatsapp,
  });

  final Order order;
  final VoidCallback onCall;
  final VoidCallback onWhatsapp;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'orders.delivery.$key'.tr(context: context);
    final lang = context.locale.languageCode;
    final courier = order.courier!;
    final active = order.status != OrderStatus.delivered;
    final eta = courier.eta;
    final etaText = courier.etaMinutes == null
        ? null
        : '${t('minutes').replaceAll('{count}', '${courier.etaMinutes}')}'
              '${eta == null ? '' : ' , ${OrdersFormatters.longDate(eta, lang)}'}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: LabeledValue(label: t('courier'), value: courier.name),
            ),
            _ContactButton(
              onTap: onCall,
              child: SvgPicture.asset(
                'assets/icons/account/call.svg',
                width: 20.w,
                height: 20.w,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            _ContactButton(
              onTap: onWhatsapp,
              child: SvgPicture.asset(
                'assets/icons/account/whatsapp.svg',
                width: 20.w,
                height: 20.w,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF25D366),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
        if (active && etaText != null) ...[
          const InfoDivider(),
          LabeledValue(label: t('expected_arrival'), value: etaText),
        ],
        if (active && courier.handoverCode != null) ...[
          const InfoDivider(),
          LabeledValue(label: t('share_code'), value: courier.handoverCode!),
        ],
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white,
    shape: const CircleBorder(side: BorderSide(color: AppColors.neutral200)),
    child: InkResponse(
      onTap: onTap,
      child: SizedBox(
        width: 44.r,
        height: 44.r,
        child: Center(child: child),
      ),
    ),
  );
}
