import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../formatters/orders_formatters.dart';

/// Asks the customer to confirm cancelling. While there is time left to cancel
/// with a refund ([window]) it is a bottom sheet with a countdown; without a
/// window it is a plain dialog. Returns true when they confirm.
Future<bool> showCancelOrderPrompt(
  BuildContext context, {
  Duration? window,
}) async {
  final Future<bool?> result = window == null
      ? showDialog<bool>(
          context: context,
          barrierColor: AppColors.overlay.withValues(alpha: 0.5),
          builder: (_) => const _CancelDialog(),
        )
      : showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: AppColors.overlay.withValues(alpha: 0.5),
          builder: (_) => _CancelSheet(window: window),
        );
  return await result ?? false;
}

class _CancelButtons extends StatelessWidget {
  const _CancelButtons({required this.canCancel});

  final bool canCancel;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'orders.cancel.$key'.tr(context: context);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textDefault,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                textStyle: AppTextStyles.textMdRegular,
              ),
              child: Text(t('keep')),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: FilledButton(
              onPressed: canCancel
                  ? () => Navigator.of(context).pop(true)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.error.withValues(alpha: 0.4),
                disabledForegroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                textStyle: AppTextStyles.textMdRegular,
              ),
              child: Text(t('confirm')),
            ),
          ),
        ),
      ],
    );
  }
}

class _CancelDialog extends StatelessWidget {
  const _CancelDialog();

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'orders.cancel.$key'.tr(context: context);
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 343.w,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.backgroundBody,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('title'),
                style: AppTextStyles.textLgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                t('message'),
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textLabel,
                ),
              ),
              SizedBox(height: 20.h),
              const _CancelButtons(canCancel: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelSheet extends StatefulWidget {
  const _CancelSheet({required this.window});

  final Duration window;

  @override
  State<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends State<_CancelSheet> {
  late Duration _left = widget.window;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _left -= const Duration(seconds: 1));
      if (_left <= Duration.zero) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'orders.cancel.$key'.tr(context: context);
    final canCancel = _left > Duration.zero;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundBody,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  PositionedDirectional(
                    end: 0,
                    child: InkResponse(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: const BoxDecoration(
                          color: AppColors.buttonSecondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 18.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                t('title'),
                textAlign: TextAlign.center,
                style: AppTextStyles.textLgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                t('message'),
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textLabel,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  t(
                    'remaining',
                  ).replaceAll('{time}', OrdersFormatters.countdown(_left)),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _CancelButtons(canCancel: canCancel),
            ],
          ),
        ),
      ),
    );
  }
}
