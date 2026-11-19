import '../../../../core/utils/result.dart';
import '../entities/store_info.dart';

abstract interface class StoreInfoRepository {
  Future<Result<StoreInfo>> getStoreInfo();
}
