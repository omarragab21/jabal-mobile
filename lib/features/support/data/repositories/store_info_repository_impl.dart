import '../../../../core/utils/result.dart';
import '../../domain/entities/store_info.dart';
import '../../domain/repositories/store_info_repository.dart';
import '../datasources/store_info_remote_data_source.dart';

class StoreInfoRepositoryImpl implements StoreInfoRepository {
  const StoreInfoRepositoryImpl(this._remote);

  final StoreInfoRemoteDataSource _remote;

  @override
  Future<Result<StoreInfo>> getStoreInfo() => guard(_remote.fetchStoreInfo);
}
