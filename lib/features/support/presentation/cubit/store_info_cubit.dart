import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/store_info.dart';
import '../../domain/usecases/support_use_cases.dart';

enum StoreInfoStatus { loading, ready, failed }

class StoreInfoState extends Equatable {
  const StoreInfoState({
    this.status = StoreInfoStatus.loading,
    this.info = const StoreInfo(),
  });

  final StoreInfoStatus status;
  final StoreInfo info;

  @override
  List<Object?> get props => [status, info];
}

/// The store's contact channels and social links, and opening them.
class StoreInfoCubit extends Cubit<StoreInfoState> {
  StoreInfoCubit({
    required GetStoreInfo getStoreInfo,
    required OpenExternalLink openLink,
  }) : _getStoreInfo = getStoreInfo,
       _openLink = openLink,
       super(const StoreInfoState());

  final GetStoreInfo _getStoreInfo;
  final OpenExternalLink _openLink;

  Future<void> load() async {
    emit(const StoreInfoState());
    final result = await _getStoreInfo();
    if (isClosed) return;
    result.when(
      success: (info) =>
          emit(StoreInfoState(status: StoreInfoStatus.ready, info: info)),
      failure: (_) =>
          emit(const StoreInfoState(status: StoreInfoStatus.failed)),
    );
  }

  /// Opens [uri]; false when no app could take it.
  Future<bool> open(Uri? uri) async {
    if (uri == null) return false;
    return (await _openLink(
      uri,
    )).when(success: (_) => true, failure: (_) => false);
  }
}
