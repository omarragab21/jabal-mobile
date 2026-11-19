import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/home_data.dart';

enum HomeStatus { loading, ready, failed }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.loading,
    this.data = const HomeData(),
    this.failure,
  });

  final HomeStatus status;
  final HomeData data;
  final Failure? failure;

  HomeState copyWith({
    HomeStatus? status,
    HomeData? data,
    Failure? Function()? failure,
  }) => HomeState(
    status: status ?? this.status,
    data: data ?? this.data,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, data, failure];
}
