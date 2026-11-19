import '../../../../core/utils/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/tax_invoice.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._remote);

  final OrdersRemoteDataSource _remote;

  @override
  Future<Result<List<Order>>> getCurrentOrders() => guard(() async {
    final orders = await _remote.fetchOrders();
    return _newestFirst(orders.where((o) => o.status.isCurrent));
  });

  @override
  Future<Result<List<Order>>> getPreviousOrders() => guard(() async {
    final orders = await _remote.fetchOrders();
    return _newestFirst(orders.where((o) => !o.status.isCurrent));
  });

  @override
  Future<Result<Order>> getOrder(String id) =>
      guard(() => _remote.fetchOrder(id));

  @override
  Future<Result<Order>> cancelOrder(String id) =>
      guard(() => _remote.cancelOrder(id));

  @override
  Future<Result<TaxInvoice>> getTaxInvoice(String orderId) =>
      guard(() => _remote.fetchTaxInvoice(orderId));

  List<Order> _newestFirst(Iterable<Order> orders) =>
      orders.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
