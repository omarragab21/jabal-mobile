import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'data/datasources/legal_data_source.dart';
import 'data/repositories/legal_repository_impl.dart';
import 'domain/entities/legal_document.dart';
import 'domain/repositories/legal_repository.dart';
import 'domain/usecases/get_legal_document.dart';
import 'presentation/pages/legal_pages.dart';

/// The version of the app, as shown on the about page.
typedef AppVersionReader = Future<String> Function();

Future<String> _readPackageVersion() async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}

/// Policies (terms, privacy) and the about page.
class LegalModule {
  LegalModule({LegalDataSource? source, AppVersionReader? readVersion})
    : _repository = LegalRepositoryImpl(
        source ?? const StaticLegalDataSource(),
      ),
      _readVersion = readVersion ?? _readPackageVersion;

  final LegalRepository _repository;
  final AppVersionReader _readVersion;

  /// The app version, e.g. "1.0.0 (1)".
  Future<String> readVersion() => _readVersion();

  /// The terms and conditions page itself, without the policies list first.
  Future<void> openTerms(BuildContext context) =>
      _openDocument(Navigator.of(context), LegalDocumentType.terms);

  /// The privacy policy page itself.
  Future<void> openPrivacy(BuildContext context) =>
      _openDocument(Navigator.of(context), LegalDocumentType.privacy);

  Future<void> openPolicies(BuildContext context) {
    final navigator = Navigator.of(context);
    return navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => PoliciesPage(
          onOpenTerms: () => _openDocument(navigator, LegalDocumentType.terms),
          onOpenPrivacy: () =>
              _openDocument(navigator, LegalDocumentType.privacy),
        ),
      ),
    );
  }

  Future<void> _openDocument(
    NavigatorState navigator,
    LegalDocumentType type,
  ) => navigator.push<void>(
    MaterialPageRoute(
      builder: (_) => LegalDocumentPage(
        type: type,
        getDocument: GetLegalDocument(_repository),
      ),
    ),
  );

  Future<void> openAbout(BuildContext context) async {
    final version = await _readVersion();
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => AboutPage(version: version)),
    );
  }
}
