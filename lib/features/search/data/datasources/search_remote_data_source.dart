/// Where search suggestions come from. [MockSearchRemoteDataSource] stands in
/// until the API exists.
abstract interface class SearchRemoteDataSource {
  Future<List<String>> fetchSuggestions(String query, String languageCode);
}
