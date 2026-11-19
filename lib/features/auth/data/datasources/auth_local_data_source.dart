import 'dart:convert';

import '../../../../core/network/token_provider.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../models/auth_session_model.dart';

abstract interface class AuthLocalDataSource {
  AuthSessionModel? readSession();
  Future<void> saveSession(AuthSessionModel session);
  Future<void> clearSession();
}

/// Keeps the session in [LocalStorage]. (Swap for a secure-storage backed
/// [LocalStorage] before shipping, since this holds the access token.)
class AuthLocalDataSourceImpl implements AuthLocalDataSource, TokenProvider {
  const AuthLocalDataSourceImpl(this._storage);

  final LocalStorage _storage;

  @override
  AuthSessionModel? readSession() {
    final token = _storage.getString(StorageKeys.authToken);
    final user = _storage.getString(StorageKeys.authUser);
    if (token == null || user == null) return null;
    try {
      return AuthSessionModel.fromJson({
        'token': token,
        'user': jsonDecode(user),
      });
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    await _storage.setString(StorageKeys.authToken, session.token);
    await _storage.setString(
      StorageKeys.authUser,
      jsonEncode((session.user as AuthUserModel).toJson()),
    );
  }

  @override
  Future<void> clearSession() async {
    await _storage.remove(StorageKeys.authToken);
    await _storage.remove(StorageKeys.authUser);
  }

  @override
  Future<String?> getAccessToken() async =>
      _storage.getString(StorageKeys.authToken);
}
