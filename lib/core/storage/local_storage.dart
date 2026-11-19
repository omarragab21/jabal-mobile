/// Read-only view of local key-value storage.
/// Classes that only read (e.g. a settings reader) depend on this alone
/// (Interface Segregation).
abstract interface class LocalStorageReader {
  String? getString(String key);
  bool? getBool(String key);
  int? getInt(String key);
  double? getDouble(String key);
  List<String>? getStringList(String key);
  bool containsKey(String key);
}

/// Write-only view of local key-value storage.
/// Every method throws `CacheException` if the write fails.
abstract interface class LocalStorageWriter {
  Future<void> setString(String key, String value);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<void> setDouble(String key, double value);
  Future<void> setStringList(String key, List<String> value);
  Future<void> remove(String key);
  Future<void> clear();
}

/// Full local storage contract. Data sources depend on this (or on one of the
/// narrower interfaces above), never on SharedPreferences directly
/// (Dependency Inversion), so the backend can be swapped or mocked.
abstract interface class LocalStorage
    implements LocalStorageReader, LocalStorageWriter {}
