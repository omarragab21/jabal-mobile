import 'package:equatable/equatable.dart';

import '../../domain/entities/main_tab.dart';

class MainState extends Equatable {
  const MainState({this.tab = MainTab.home, this.cartCount = 0});

  final MainTab tab;
  final int cartCount;

  MainState copyWith({MainTab? tab, int? cartCount}) =>
      MainState(tab: tab ?? this.tab, cartCount: cartCount ?? this.cartCount);

  @override
  List<Object?> get props => [tab, cartCount];
}
