import '../../../home/data/datasources/mock_home_payloads.dart';
import '../../domain/services/search_text.dart';
import 'mock_search_payloads.dart';
import 'search_remote_data_source.dart';

/// Demo backend: the curated phrases plus the shop's product and category
/// names, filtered and ordered by how well they match, after a short fake
/// network delay.
class MockSearchRemoteDataSource implements SearchRemoteDataSource {
  const MockSearchRemoteDataSource({
    this.latency = const Duration(milliseconds: 150),
  });

  final Duration latency;

  @override
  Future<List<String>> fetchSuggestions(
    String query,
    String languageCode,
  ) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final lang = languageCode == 'ar' ? 'ar' : 'en';
    final candidates = <String>[
      ...?mockSuggestionPhrases[lang],
      for (final product in mockProducts(lang)) product['name'] as String,
      ..._categoryNames(lang),
    ];
    final matching = [
      for (final candidate in candidates)
        if (SearchText.matches(candidate, query)) candidate,
    ];
    // Stable sort: phrases that start with the query first, curated phrases
    // before product names among equals.
    final ranked = [for (var i = 0; i < matching.length; i++) (matching[i], i)]
      ..sort((a, b) {
        final byRank = SearchText.rank(
          a.$1,
          query,
        ).compareTo(SearchText.rank(b.$1, query));
        return byRank != 0 ? byRank : a.$2.compareTo(b.$2);
      });
    return [for (final item in ranked) item.$1];
  }

  static Iterable<String> _categoryNames(String lang) sync* {
    for (final root in mockCategories) {
      yield _name(root, lang);
      for (final child in (root['sub_categories'] as List? ?? const [])) {
        yield _name(child as Map<String, dynamic>, lang);
      }
    }
  }

  static String _name(Map<String, dynamic> category, String lang) {
    final translations = category['translations'] as Map<String, dynamic>?;
    final localized = (translations?[lang] as Map?)?['name'];
    return (localized ?? category['name'] ?? '') as String;
  }
}
