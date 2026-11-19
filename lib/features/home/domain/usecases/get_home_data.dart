import '../../../../core/utils/result.dart';
import '../entities/home_data.dart';
import '../repositories/home_repository.dart';

class GetHomeData {
  const GetHomeData(this._repository);
  final HomeRepository _repository;

  Future<Result<HomeData>> call(String languageCode) =>
      _repository.getHome(languageCode);
}
