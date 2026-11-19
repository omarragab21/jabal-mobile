import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/usecases/orders_use_cases.dart';

enum OrdersStatus { loading, ready, failed }

enum OrdersTab { current, previous }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersStatus.loading,
    this.tab = OrdersTab.current,
    this.current = const [],
    this.previous = const [],
  });

  final OrdersStatus status;
  final OrdersTab tab;
  final List<Order> current;
  final List<Order> previous;

  /// The orders of the selected tab.
  List<Order> get visible => tab == OrdersTab.current ? current : previous;

  OrdersState copyWith({
    OrdersStatus? status,
    OrdersTab? tab,
    List<Order>? current,
    List<Order>? previous,
  }) => OrdersState(
    status: status ?? this.status,
    tab: tab ?? this.tab,
    current: current ?? this.current,
    previous: previous ?? this.previous,
  );

  @override
  List<Object?> get props => [status, tab, current, previous];
}

/// View model of "my orders": both lists and the selected tab.
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({
    required GetCurrentOrders getCurrentOrders,
    required GetPreviousOrders getPreviousOrders,
  }) : _getCurrent = getCurrentOrders,
       _getPrevious = getPreviousOrders,
       super(const OrdersState());

  final GetCurrentOrders _getCurrent;
  final GetPreviousOrders _getPrevious;

  /// Loads both lists. [silent] keeps what is on screen while refreshing
  /// (coming back from the details page).
  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: OrdersStatus.loading));
    final results = await Future.wait([_getCurrent(), _getPrevious()]);
    if (isClosed) return;
    final current = results[0];
    final previous = results[1];
    final failed =
        current.when(success: (_) => false, failure: (_) => true) ||
        previous.when(success: (_) => false, failure: (_) => true);
    if (failed) {
      emit(state.copyWith(status: OrdersStatus.failed));
      return;
    }
    emit(
      state.copyWith(
        status: OrdersStatus.ready,
        current: current.when(success: (v) => v, failure: (_) => const []),
        previous: previous.when(success: (v) => v, failure: (_) => const []),
      ),
    );
  }

  void selectTab(OrdersTab tab) {
    if (tab != state.tab) emit(state.copyWith(tab: tab));
  }
}
