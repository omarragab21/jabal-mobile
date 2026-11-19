import 'package:shared_preferences/shared_preferences.dart';

import '../error/exceptions.dart';
import 'local_storage.dart';

/// SharedPreferences-backed implementation of [LocalStorage].
/// Any failure is reported as a [CacheException], so SharedPreferences
/// details never leak out of this class.
class SharedPrefsStorage implements LocalStorage {
  SharedPrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  /// Async factory used once at app start-up (e.g. in the DI setup).
  static Future<SharedPrefsStorage> create() async =>
      SharedPrefsStorage(await SharedPreferences.getInstance());

  // ---- reads ----
  @override
  String? getString(String key) => _read(() => _prefs.getString(key));

  @override
  bool? getBool(String key) => _read(() => _prefs.getBool(key));

  @override
  int? getInt(String key) => _read(() => _prefs.getInt(key));

  @override
  double? getDouble(String key) => _read(() => _prefs.getDouble(key));

  @override
  List<String>? getStringList(String key) =>
      _read(() => _prefs.getStringList(key));

  @override
  bool containsKey(String key) => _read(() => _prefs.containsKey(key));

  // ---- writes ----
  @override
  Future<void> setString(String key, String value) =>
      _write(() => _prefs.setString(key, value));

  @override
  Future<void> setBool(String key, bool value) =>
      _write(() => _prefs.setBool(key, value));

  @override
  Future<void> setInt(String key, int value) =>
      _write(() => _prefs.setInt(key, value));

  @override
  Future<void> setDouble(String key, double value) =>
      _write(() => _prefs.setDouble(key, value));

  @override
  Future<void> setStringList(String key, List<String> value) =>
      _write(() => _prefs.setStringList(key, value));

  @override
  Future<void> remove(String key) => _write(() => _prefs.remove(key));

  @override
  Future<void> clear() => _write(() => _prefs.clear());

  // ---- helpers ----
  T _read<T>(T Function() read) {
    try {
      return read();
    } catch (_) {
      // e.g. a stored value has a different type than requested.
      throw const CacheException('Failed to read from local storage');
    }
  }

  Future<void> _write(Future<bool> Function() write) async {
    try {
      final ok = await write();
      if (!ok) throw const CacheException('Failed to write to local storage');
    } on CacheException {
      rethrow;
    } catch (_) {
      throw const CacheException('Failed to write to local storage');
    }
  }
}
