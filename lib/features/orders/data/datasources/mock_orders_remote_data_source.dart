import '../../../../core/error/exceptions.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/tax_invoice.dart';
import '../models/order_model.dart';
import '../models/tax_invoice_model.dart';
import 'mock_orders_payloads.dart';
import 'orders_remote_data_source.dart';

/// Demo backend: API-shaped payloads parsed by the real models, after a short
/// fake network delay. Cancelling really changes the order, so the lists and
/// the details page stay consistent while the app runs.
class MockOrdersRemoteDataSource implements OrdersRemoteDataSource {
  MockOrdersRemoteDataSource({
    this.latency = const Duration(milliseconds: 500),
    DateTime Function() now = DateTime.now,
  }) : _now = now,
       _orders = [for (final json in mockOrders) OrderModel.fromJson(json)];

  final Duration latency;
  final DateTime Function() _now;
  final List<Order> _orders;

  Future<T> _respond<T>(T Function() build) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return build();
  }

  int _indexOf(String id) {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0) throw const NotFoundException();
    return index;
  }

  @override
  Future<List<Order>> fetchOrders() =>
      _respond(() => List<Order>.unmodifiable(_orders));

  @override
  Future<Order> fetchOrder(String id) => _respond(() => _orders[_indexOf(id)]);

  @override
  Future<Order> cancelOrder(String id) => _respond(() {
    final index = _indexOf(id);
    final order = _orders[index];
    if (!order.canCancel) {
      throw const ServerException('Order can no longer be cancelled');
    }
    final kept = [
      for (final step in order.timeline)
        if (step.state == TimelineStepState.done ||
            step.kind == TimelineStepKind.awaitingStore)
          OrderTimelineStep(
            kind: step.kind,
            state: TimelineStepState.done,
            time: step.time,
          ),
    ];
    final cancelled = order.copyWith(
      status: OrderStatus.cancelled,
      cancelledBy: CancelledBy.customer,
      clearCancelWindow: true,
      timeline: [
        ...kept,
        OrderTimelineStep(
          kind: TimelineStepKind.cancelled,
          state: TimelineStepState.current,
          time: _now(),
        ),
      ],
    );
    _orders[index] = cancelled;
    return cancelled;
  });

  @override
  Future<TaxInvoice> fetchTaxInvoice(String orderId) => _respond(() {
    _indexOf(orderId);
    return TaxInvoiceModel.fromJson(mockTaxInvoice);
  });
}
