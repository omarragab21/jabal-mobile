import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/user_profile.dart';

/// Where the profile lives on the device. The name, phone and e-mail are the
/// signed-in user kept by the auth feature (`auth_user`), so a change shows
/// everywhere at once; gender and birth date are extras kept beside it.
abstract interface class ProfileLocalDataSource {
  /// Null when nobody is signed in.
  UserProfile? read();

  Future<void> write(UserProfile profile);
}

class StorageProfileLocalDataSource implements ProfileLocalDataSource {
  const StorageProfileLocalDataSource(this._storage);

  final LocalStorage _storage;

  Map<String, dynamic> _json(String key) {
    final raw = _storage.getString(key);
    if (raw == null) return const {};
    try {
      return JsonReader.map(jsonDecode(raw));
    } on FormatException {
      return const {};
    }
  }

  @override
  UserProfile? read() {
    final user = _json(StorageKeys.authUser);
    final id = JsonReader.stringOrNull(user['id']);
    final name = JsonReader.stringOrNull(user['name']);
    final phone = JsonReader.stringOrNull(user['phone']);
    if (id == null || name == null || phone == null) return null;
    final extras = _json(StorageKeys.profileExtras);
    return UserProfile(
      id: id,
      name: name,
      phone: phone,
      email: JsonReader.stringOrNull(user['email']),
      gender: Gender.parse(JsonReader.stringOrNull(extras['gender'])),
      birthDate: DateTime.tryParse(JsonReader.string(extras['birthDate'])),
    );
  }

  @override
  Future<void> write(UserProfile profile) async {
    await _storage.setString(
      StorageKeys.authUser,
      jsonEncode({
        'id': profile.id,
        'name': profile.name,
        'phone': profile.phone,
        'email': profile.email,
      }),
    );
    await _storage.setString(
      StorageKeys.profileExtras,
      jsonEncode({
        'gender': profile.gender?.name,
        'birthDate': profile.birthDate?.toIso8601String(),
      }),
    );
  }
}
