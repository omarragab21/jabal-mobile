import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/platform/link_opener.dart';
import 'data/datasources/mock_orders_remote_data_source.dart';
import 'data/datasources/orders_remote_data_source.dart';
import 'data/repositories/orders_repository_impl.dart';
import 'domain/entities/order.dart';
import 'domain/repositories/orders_repository.dart';
import 'domain/usecases/orders_use_cases.dart';
import 'presentation/cubit/order_details_cubit.dart';
import 'presentation/cubit/orders_cubit.dart';
import 'presentation/cubit/tax_invoice_cubit.dart';
import 'presentation/pages/order_details_page.dart';
import 'presentation/pages/orders_page.dart';
import 'presentation/pages/tax_invoice_page.dart';

/// The orders feature: the lists (current and previous), one order's page with
/// cancelling, and its tax invoice. Pass a real [OrdersRemoteDataSource] to
/// replace the mock.
class OrdersModule {
  OrdersModule({
    OrdersRemoteDataSource? remote,
    LinkOpener? linkOpener,
    Future<void> Function(BuildContext context)? openSupport,
    Duration latency = const Duration(milliseconds: 500),
  }) : _repository = OrdersRepositoryImpl(
         remote ?? MockOrdersRemoteDataSource(latency: latency),
       ),
       _opener = linkOpener ?? const UrlLauncherLinkOpener(),
       _openSupport = openSupport;

  final OrdersRepository _repository;
  final LinkOpener _opener;
  final Future<void> Function(BuildContext context)? _openSupport;

  /// The "my orders" tab. [onDiscoverProducts] is the empty lists' button.
  Widget page({required VoidCallback onDiscoverProducts}) => BlocProvider(
    create: (_) => OrdersCubit(
      getCurrentOrders: GetCurrentOrders(_repository),
      getPreviousOrders: GetPreviousOrders(_repository),
    )..load(),
    child: Builder(
      builder: (pageContext) => OrdersPage(
        onOpenOrder: (order) => _openDetails(pageContext, order),
        onDiscoverProducts: onDiscoverProducts,
      ),
    ),
  );

  Future<void> _openDetails(BuildContext context, Order order) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => OrderDetailsCubit(
              orderId: order.id,
              getOrder: GetOrderDetails(_repository),
              cancelOrder: CancelOrder(_repository),
            )..load(),
            child: Builder(
              builder: (detailsContext) => OrderDetailsPage(
                onHelp: () => _openSupport?.call(detailsContext),
                onCall: (phone) =>
                    _opener.open(Uri(scheme: 'tel', path: '+$phone')),
                onWhatsapp: (phone) =>
                    _opener.open(Uri.https('wa.me', '/$phone')),
                onViewInvoice: (order) => _openInvoice(detailsContext, order),
              ),
            ),
          ),
        ),
      );

  Future<void> _openInvoice(BuildContext context, Order order) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => TaxInvoiceCubit(
              orderId: order.id,
              getInvoice: GetTaxInvoice(_repository),
            )..load(),
            child: const TaxInvoicePage(),
          ),
        ),
      );
}
