import '../../../../core/utils/result.dart';
import '../entities/order.dart';
import '../entities/tax_invoice.dart';

abstract interface class OrdersRepository {
  /// Orders still moving: pending approval, in preparation, on the way.
  Future<Result<List<Order>>> getCurrentOrders();

  /// Delivered and cancelled orders.
  Future<Result<List<Order>>> getPreviousOrders();

  Future<Result<Order>> getOrder(String id);

  /// Cancels an order and returns it as it is afterwards.
  Future<Result<Order>> cancelOrder(String id);

  Future<Result<TaxInvoice>> getTaxInvoice(String orderId);
}
