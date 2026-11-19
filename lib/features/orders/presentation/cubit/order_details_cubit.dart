import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/usecases/orders_use_cases.dart';

enum OrderDetailsStatus { loading, ready, failed }

/// The collapsible cards of the details page.
enum OrderSection {
  delivery,
  products,
  recipient,
  payment,
  timeline;

  /// Shown folded open, as in the design.
  static const Set<OrderSection> initiallyOpen = {...values};
}

class OrderDetailsState extends Equatable {
  const OrderDetailsState({
    this.status = OrderDetailsStatus.loading,
    this.order,
    this.cancelling = false,
    this.open = OrderSection.initiallyOpen,
  });

  final OrderDetailsStatus status;
  final Order? order;
  final bool cancelling;
  final Set<OrderSection> open;

  bool isOpen(OrderSection section) => open.contains(section);

  OrderDetailsState copyWith({
    OrderDetailsStatus? status,
    Order? order,
    bool? cancelling,
    Set<OrderSection>? open,
  }) => OrderDetailsState(
    status: status ?? this.status,
    order: order ?? this.order,
    cancelling: cancelling ?? this.cancelling,
    open: open ?? this.open,
  );

  @override
  List<Object?> get props => [status, order, cancelling, open];
}

/// View model of one order's page.
class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit({
    required this.orderId,
    required GetOrderDetails getOrder,
    required CancelOrder cancelOrder,
  }) : _getOrder = getOrder,
       _cancelOrder = cancelOrder,
       super(const OrderDetailsState());

  final String orderId;
  final GetOrderDetails _getOrder;
  final CancelOrder _cancelOrder;

  Future<void> load() async {
    emit(state.copyWith(status: OrderDetailsStatus.loading));
    final result = await _getOrder(orderId);
    if (isClosed) return;
    result.when(
      success: (order) =>
          emit(state.copyWith(status: OrderDetailsStatus.ready, order: order)),
      failure: (_) => emit(state.copyWith(status: OrderDetailsStatus.failed)),
    );
  }

  void toggle(OrderSection section) {
    final open = {...state.open};
    if (!open.remove(section)) open.add(section);
    emit(state.copyWith(open: open));
  }

  /// Cancels the order; true when it worked.
  Future<bool> cancel() async {
    if (state.cancelling) return false;
    emit(state.copyWith(cancelling: true));
    final result = await _cancelOrder(orderId);
    if (isClosed) return false;
    return result.when(
      success: (order) {
        emit(state.copyWith(order: order, cancelling: false));
        return true;
      },
      failure: (_) {
        emit(state.copyWith(cancelling: false));
        return false;
      },
    );
  }
}
