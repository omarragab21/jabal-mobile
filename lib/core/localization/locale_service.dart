import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../storage/local_storage.dart';
import '../storage/storage_keys.dart';
import 'app_localization.dart';

/// Reads/writes the chosen language. Arabic is the default.
class LocaleService {
  const LocaleService(this._storage);

  final LocalStorage _storage;

  Locale load() {
    final code = _storage.getString(StorageKeys.languageCode);
    return AppLocalization.supported.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => AppLocalization.fallback,
    );
  }

  Future<void> save(Locale locale) =>
      _storage.setString(StorageKeys.languageCode, locale.languageCode);

  /// Switches Arabic <-> English. Text direction flips automatically because
  /// MaterialApp derives it from the locale (ar = RTL, en = LTR).
  Future<void> toggle(BuildContext context) async {
    final next = context.locale.languageCode == 'ar'
        ? AppLocalization.english
        : AppLocalization.arabic;
    await context.setLocale(next);
    await save(next);
  }
}
