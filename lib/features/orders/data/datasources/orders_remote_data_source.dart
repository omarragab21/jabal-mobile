import '../../domain/entities/order.dart';
import '../../domain/entities/tax_invoice.dart';

/// Where orders come from. [MockOrdersRemoteDataSource] stands in until the
/// API exists; the real implementation only has to satisfy this contract.
abstract interface class OrdersRemoteDataSource {
  Future<List<Order>> fetchOrders();

  Future<Order> fetchOrder(String id);

  Future<Order> cancelOrder(String id);

  Future<TaxInvoice> fetchTaxInvoice(String orderId);
}
