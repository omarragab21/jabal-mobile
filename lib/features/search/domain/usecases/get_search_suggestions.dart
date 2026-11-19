import '../../../../core/utils/result.dart';
import '../repositories/search_repository.dart';

/// The suggestions shown while the customer types.
class GetSearchSuggestions {
  const GetSearchSuggestions(this._repository);
  final SearchRepository _repository;

  /// The most suggestions to show.
  static const int maxCount = 8;

  /// Nothing for a blank query. The list is trimmed to [maxCount] and has no
  /// repeats, whatever the data source sent.
  Future<Result<List<String>>> call(String query, String languageCode) async {
    final text = query.trim();
    if (text.isEmpty) return const Success([]);
    final result = await _repository.getSuggestions(text, languageCode);
    return result.when(
      success: (list) => Success(_clean(list, text)),
      failure: Err.new,
    );
  }

  List<String> _clean(List<String> list, String query) {
    final seen = <String>{};
    return [
      for (final item in list)
        if (item.trim().isNotEmpty && seen.add(item.trim())) item.trim(),
    ].take(maxCount).toList();
  }
}
