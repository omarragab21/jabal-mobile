import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_tab_page.dart';
import '../../domain/entities/order.dart';
import '../cubit/orders_cubit.dart';
import '../widgets/order_card.dart';
import '../widgets/orders_empty_view.dart';
import '../widgets/orders_tabs.dart';

/// "طلباتي": the current and previous orders in two tabs.
class OrdersPage extends StatelessWidget {
  const OrdersPage({
    super.key,
    required this.onOpenOrder,
    required this.onDiscoverProducts,
  });

  /// Opens the details of an order; completes when the page is closed.
  final Future<void> Function(Order order) onOpenOrder;
  final VoidCallback onDiscoverProducts;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrdersCubit>();
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) => AppTabPage(
        title: 'nav.orders'.tr(context: context),
        body: Column(
          children: [
            OrdersTabs(selected: state.tab, onSelect: cubit.selectTab),
            Expanded(
              child: ColoredBox(
                color: AppColors.backgroundBody,
                child: switch (state.status) {
                  OrdersStatus.loading => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  OrdersStatus.failed => Center(
                    child: TextButton(
                      onPressed: cubit.load,
                      child: Text('home.retry'.tr(context: context)),
                    ),
                  ),
                  OrdersStatus.ready when state.visible.isEmpty => _empty(
                    context,
                    state.tab,
                  ),
                  OrdersStatus.ready => RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => cubit.load(silent: true),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.r),
                      itemCount: state.visible.length,
                      separatorBuilder: (_, _) => SizedBox(height: 16.h),
                      itemBuilder: (_, index) {
                        final order = state.visible[index];
                        return OrderCard(
                          order: order,
                          onTap: () async {
                            await onOpenOrder(order);
                            // The order may have been cancelled meanwhile.
                            await cubit.load(silent: true);
                          },
                        );
                      },
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context, OrdersTab tab) {
    String t(String key) =>
        'orders.empty_${tab.name}.$key'.tr(context: context);
    return OrdersEmptyView(
      title: t('title'),
      message: t('message'),
      actionLabel: t('action'),
      onAction: onDiscoverProducts,
    );
  }
}
