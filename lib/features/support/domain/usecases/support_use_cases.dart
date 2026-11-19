import '../../../../core/error/failures.dart';
import '../../../../core/platform/link_opener.dart';
import '../../../../core/utils/result.dart';
import '../entities/store_info.dart';
import '../repositories/store_info_repository.dart';

class GetStoreInfo {
  const GetStoreInfo(this._repository);
  final StoreInfoRepository _repository;

  Future<Result<StoreInfo>> call() => _repository.getStoreInfo();
}

/// Opens a link outside the app; a failure when nothing can handle it.
class OpenExternalLink {
  const OpenExternalLink(this._opener);
  final LinkOpener _opener;

  Future<Result<void>> call(Uri uri) async => await _opener.open(uri)
      ? const Success(null)
      : const Err(UnknownFailure('Could not open the link'));
}
