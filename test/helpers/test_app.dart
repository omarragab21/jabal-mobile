import 'dart:convert';
import 'dart:io';

import 'package:dr_jabel/core/error/exceptions.dart';
import 'package:dr_jabel/core/localization/app_localization.dart';
import 'package:dr_jabel/core/platform/link_opener.dart';
import 'package:dr_jabel/core/localization/locale_service.dart';
import 'package:dr_jabel/core/storage/shared_prefs_storage.dart';
import 'package:dr_jabel/features/address/data/datasources/device_location_data_source.dart';
import 'package:dr_jabel/features/address/data/datasources/mock_places_remote_data_source.dart';
import 'package:dr_jabel/features/auth/data/datasources/mock_auth_remote_data_source.dart';
import 'package:dr_jabel/features/home/data/datasources/home_remote_data_source.dart';
import 'package:dr_jabel/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:dr_jabel/features/support/data/datasources/store_info_remote_data_source.dart';
import 'package:dr_jabel/features/home/data/datasources/mock_home_remote_data_source.dart';
import 'package:dr_jabel/main.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_map.dart';

/// Remembers the links instead of leaving the app.
class RecordingLinkOpener implements LinkOpener {
  RecordingLinkOpener({this.result = true});

  final bool result;
  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return result;
  }
}

/// Reads the real translation files from disk (no async asset I/O).
class FileAssetLoader extends AssetLoader {
  const FileAssetLoader();
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}

/// Boots the whole app on an iPhone 14 Pro sized screen.
Future<void> pumpApp(
  WidgetTester tester,
  Map<String, Object> prefs, {
  Size size = const Size(1179, 2556),
  bool waitSplash = true,
  HomeRemoteDataSource? homeRemote,
  DeviceLocationDataSource? deviceLocation,
  LinkOpener? linkOpener,
  StoreInfoRemoteDataSource? storeInfoRemote,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);
  await EasyLocalization.ensureInitialized();
  final storage = await SharedPrefsStorage.create();
  final service = LocaleService(storage);
  await tester.pumpWidget(
    AppLocalization.wrap(
      startLocale: service.load(),
      assetLoader: const FileAssetLoader(),
      child: MyApp(
        router: buildAppRouter(
          storage,
          authRemote: MockAuthRemoteDataSource(latency: Duration.zero),
          homeRemote:
              homeRemote ??
              const MockHomeRemoteDataSource(latency: Duration.zero),
          placesRemote: const MockPlacesRemoteDataSource(
            latency: Duration.zero,
          ),
          deviceLocation:
              deviceLocation ??
              FakeDeviceLocation(error: const LocationDisabledException()),
          mapBuilder: FakeMapCanvas.build,
          linkOpener: linkOpener ?? RecordingLinkOpener(),
          storeInfoRemote:
              storeInfoRemote ??
              const MockStoreInfoRemoteDataSource(latency: Duration.zero),
          profileRemote: const MockProfileRemoteDataSource(
            latency: Duration.zero,
          ),
          readVersion: () async => '1.2.3 (45)',
          // A running news bar would keep pumpAndSettle from ever settling.
          animations: false,
        ),
        localeService: service,
      ),
    ),
  );
  await settle(tester);
  if (waitSplash) {
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);
  }
}

/// Translation files load through real async I/O, so give them real time.
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pumpAndSettle();
}

TextDirection directionOf(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(Scaffold).first));
