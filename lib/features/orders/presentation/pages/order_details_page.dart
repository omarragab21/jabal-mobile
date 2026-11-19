import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../cubit/order_details_cubit.dart';
import '../widgets/cancel_order_sheet.dart';
import '../widgets/order_delivery_section.dart';
import '../widgets/order_payment_section.dart';
import '../widgets/order_products_section.dart';
import '../widgets/order_recipient_section.dart';
import '../widgets/order_status_banner.dart';
import '../widgets/order_timeline_section.dart';
import '../widgets/section_card.dart';

/// One order: its status, delivery, products, recipient, payment and journey,
/// with "cancel" while allowed and "view invoice" once delivered.
class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    super.key,
    required this.onHelp,
    required this.onCall,
    required this.onWhatsapp,
    required this.onViewInvoice,
  });

  final VoidCallback onHelp;
  final void Function(String phone) onCall;
  final void Function(String phone) onWhatsapp;
  final void Function(Order order) onViewInvoice;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrderDetailsCubit>();
    return BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
      builder: (context, state) {
        final order = state.order;
        return AppSubPage(
          title: 'orders.details_title'.tr(context: context),
          backgroundColor: AppColors.backgroundBody,
          loading: state.cancelling,
          trailing: _HelpButton(onTap: onHelp),
          body: switch (state.status) {
            OrderDetailsStatus.loading => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            OrderDetailsStatus.failed => Center(
              child: TextButton(
                onPressed: cubit.load,
                child: Text('home.retry'.tr(context: context)),
              ),
            ),
            OrderDetailsStatus.ready => _Content(
              order: order!,
              state: state,
              onToggle: cubit.toggle,
              onCancel: () => _cancel(context, order),
              onCall: onCall,
              onWhatsapp: onWhatsapp,
              onViewInvoice: () => onViewInvoice(order),
            ),
          },
        );
      },
    );
  }

  Future<void> _cancel(BuildContext context, Order order) async {
    final cubit = context.read<OrderDetailsCubit>();
    final confirmed = await showCancelOrderPrompt(
      context,
      window: order.cancelWindow,
    );
    if (!confirmed || !context.mounted) return;
    final done = await cubit.cancel();
    if (!context.mounted) return;
    showAppToast(
      context,
      (done ? 'orders.toast.cancelled_refunded' : 'orders.toast.cancel_failed')
          .tr(context: context),
      error: !done,
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.order,
    required this.state,
    required this.onToggle,
    required this.onCancel,
    required this.onCall,
    required this.onWhatsapp,
    required this.onViewInvoice,
  });

  final Order order;
  final OrderDetailsState state;
  final void Function(OrderSection section) onToggle;
  final VoidCallback onCancel;
  final void Function(String phone) onCall;
  final void Function(String phone) onWhatsapp;
  final VoidCallback onViewInvoice;

  @override
  Widget build(BuildContext context) {
    String t(String key) => 'orders.$key'.tr(context: context);
    Widget section(OrderSection s, String title, Widget child) => SectionCard(
      title: title,
      open: state.isOpen(s),
      onToggle: () => onToggle(s),
      child: child,
    );
    final courier = order.courier;
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        OrderStatusBanner(order: order),
        SizedBox(height: 16.h),
        if (order.isSearchingCourier) ...[
          const SearchingCourierCard(),
          SizedBox(height: 16.h),
        ],
        if (courier != null && order.status != OrderStatus.cancelled) ...[
          section(
            OrderSection.delivery,
            t('delivery.title'),
            OrderDeliveryContent(
              order: order,
              onCall: () => onCall(courier.phone),
              onWhatsapp: () => onWhatsapp(courier.phone),
            ),
          ),
          SizedBox(height: 16.h),
        ],
        section(
          OrderSection.products,
          t('products'),
          OrderProductsList(items: order.items),
        ),
        SizedBox(height: 16.h),
        section(
          OrderSection.recipient,
          t('recipient.title'),
          OrderRecipientContent(recipient: order.recipient),
        ),
        SizedBox(height: 16.h),
        section(
          OrderSection.payment,
          t('payment.title'),
          OrderPaymentContent(order: order),
        ),
        SizedBox(height: 16.h),
        section(
          OrderSection.timeline,
          t('timeline.title'),
          OrderTimelineContent(steps: order.timeline),
        ),
        if (order.canCancel) ...[
          SizedBox(height: 16.h),
          _OutlinedAction(label: t('cancel.action'), onTap: onCancel),
        ],
        if (order.status == OrderStatus.delivered) ...[
          SizedBox(height: 16.h),
          AppButton(label: t('view_invoice'), onPressed: onViewInvoice),
        ],
        SizedBox(height: 16.h),
      ],
    );
  }
}

class _OutlinedAction extends StatelessWidget {
  const _OutlinedAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44.h,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textDefault,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
        textStyle: AppTextStyles.textMdRegular,
      ),
      child: Text(label),
    ),
  );
}

/// "Help" outlined button with a headset, at the end of the header.
class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textDefault,
        side: const BorderSide(color: AppColors.border),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        minimumSize: Size(0, 32.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
        textStyle: AppTextStyles.textSmRegular,
      ),
      icon: SvgPicture.asset(
        'assets/icons/account/support.svg',
        width: 18.w,
        height: 18.w,
        colorFilter: const ColorFilter.mode(
          AppColors.textDefault,
          BlendMode.srcIn,
        ),
      ),
      label: Text('orders.help'.tr(context: context)),
    );
  }
}
