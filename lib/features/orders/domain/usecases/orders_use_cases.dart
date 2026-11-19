import '../../../../core/utils/result.dart';
import '../entities/order.dart';
import '../entities/tax_invoice.dart';
import '../repositories/orders_repository.dart';

class GetCurrentOrders {
  const GetCurrentOrders(this._repository);
  final OrdersRepository _repository;

  Future<Result<List<Order>>> call() => _repository.getCurrentOrders();
}

class GetPreviousOrders {
  const GetPreviousOrders(this._repository);
  final OrdersRepository _repository;

  Future<Result<List<Order>>> call() => _repository.getPreviousOrders();
}

class GetOrderDetails {
  const GetOrderDetails(this._repository);
  final OrdersRepository _repository;

  Future<Result<Order>> call(String id) => _repository.getOrder(id);
}

class CancelOrder {
  const CancelOrder(this._repository);
  final OrdersRepository _repository;

  Future<Result<Order>> call(String id) => _repository.cancelOrder(id);
}

class GetTaxInvoice {
  const GetTaxInvoice(this._repository);
  final OrdersRepository _repository;

  Future<Result<TaxInvoice>> call(String orderId) =>
      _repository.getTaxInvoice(orderId);
}
