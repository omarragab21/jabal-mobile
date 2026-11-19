import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

/// Single place for the app's localization setup (Arabic default, English).
abstract final class AppLocalization {
  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');
  static const List<Locale> supported = [arabic, english];
  static const Locale fallback = arabic;
  static const String path = 'assets/translations';

  /// Wraps the app. The saved language is passed as [startLocale]; saving is
  /// done by [LocaleService] so persistence goes through `LocalStorage`.
  static Widget wrap({
    required Locale startLocale,
    required Widget child,
    AssetLoader assetLoader = const RootBundleAssetLoader(),
  }) => EasyLocalization(
    supportedLocales: supported,
    path: path,
    assetLoader: assetLoader,
    fallbackLocale: fallback,
    startLocale: startLocale,
    saveLocale: false,
    useOnlyLangCode: true,
    child: child,
  );
}
