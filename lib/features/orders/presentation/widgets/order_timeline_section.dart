import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order.dart';
import '../formatters/orders_formatters.dart';

/// The order's journey, step by step, joined by a vertical line.
class OrderTimelineContent extends StatelessWidget {
  const OrderTimelineContent({super.key, required this.steps});

  final List<OrderTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _StepRow(
            step: steps[i],
            last: i == steps.length - 1,
            label: 'orders.timeline.${_key(steps[i].kind)}'.tr(
              context: context,
            ),
            date: OrdersFormatters.longDate(steps[i].time, lang),
          ),
      ],
    );
  }

  static String _key(TimelineStepKind kind) => switch (kind) {
    TimelineStepKind.received => 'received',
    TimelineStepKind.awaitingStore => 'awaiting_store',
    TimelineStepKind.accepted => 'accepted',
    TimelineStepKind.preparing => 'preparing',
    TimelineStepKind.handedToCourier => 'handed_to_courier',
    TimelineStepKind.delivered => 'delivered',
    TimelineStepKind.cancelled => 'cancelled',
  };
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.last,
    required this.label,
    required this.date,
  });

  final OrderTimelineStep step;
  final bool last;
  final String label;
  final String date;

  static IconData _icon(TimelineStepKind kind) => switch (kind) {
    TimelineStepKind.received => Icons.inventory_2_outlined,
    TimelineStepKind.awaitingStore => Icons.warning_amber_rounded,
    TimelineStepKind.accepted => Icons.check,
    TimelineStepKind.preparing => Icons.restaurant_outlined,
    TimelineStepKind.handedToCourier => Icons.directions_car_outlined,
    TimelineStepKind.delivered => Icons.check,
    TimelineStepKind.cancelled => Icons.close,
  };

  @override
  Widget build(BuildContext context) {
    final (circle, icon) = switch (step.state) {
      TimelineStepState.done => (const Color(0xFFF7FFF3), AppColors.primary),
      TimelineStepState.current => (AppColors.primary, AppColors.white),
      TimelineStepState.upcoming => (
        AppColors.neutral200,
        AppColors.textDisabled,
      ),
    };
    final line = step.state == TimelineStepState.done
        ? const Color(0xFFF7FFF3)
        : AppColors.neutral200;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24.r,
            child: Column(
              children: [
                Container(
                  width: 24.r,
                  height: 24.r,
                  decoration: BoxDecoration(
                    color: circle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon(step.kind), size: 14.r, color: icon),
                ),
                if (!last)
                  Expanded(
                    child: Container(width: 2.w, color: line),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.textMdRegular.copyWith(
                      color: AppColors.textDefault,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    date,
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
