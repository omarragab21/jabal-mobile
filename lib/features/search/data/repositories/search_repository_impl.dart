import '../../../../core/utils/result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl(this._remote);

  final SearchRemoteDataSource _remote;

  @override
  Future<Result<List<String>>> getSuggestions(
    String query,
    String languageCode,
  ) => guard(() => _remote.fetchSuggestions(query, languageCode));
}
