import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/domain/usecases/watch_cart_count.dart';
import '../../domain/entities/main_tab.dart';
import 'main_state.dart';

/// Holds the selected tab and the cart badge count.
class MainCubit extends Cubit<MainState> {
  MainCubit(
    this._watchCartCount, {
    MainTab initial = MainTab.home,
    Stream<MainTab> tabRequests = const Stream.empty(),
  }) : super(MainState(tab: initial)) {
    _requests = tabRequests.listen(select);
    _sub = _watchCartCount().listen(
      (count) => emit(state.copyWith(cartCount: count)),
    );
  }

  final WatchCartCount _watchCartCount;
  late final StreamSubscription<int> _sub;
  late final StreamSubscription<MainTab> _requests;

  void select(MainTab tab) {
    if (tab != state.tab) emit(state.copyWith(tab: tab));
  }

  @override
  Future<void> close() {
    _sub.cancel();
    _requests.cancel();
    return super.close();
  }
}
