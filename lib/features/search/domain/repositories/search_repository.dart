import '../../../../core/utils/result.dart';

abstract interface class SearchRepository {
  /// Texts worth completing [query] to, best first, in [languageCode]
  /// (`ar` / `en`).
  Future<Result<List<String>>> getSuggestions(
    String query,
    String languageCode,
  );
}
