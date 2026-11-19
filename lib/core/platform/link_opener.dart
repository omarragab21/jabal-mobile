import 'package:url_launcher/url_launcher.dart';

/// Opens a link outside the app (WhatsApp, the browser, the phone dialer).
/// Features depend on this, not on `url_launcher`, so tests can record the
/// links instead of leaving the app.
abstract interface class LinkOpener {
  /// True when another app took the link.
  Future<bool> open(Uri uri);
}

class UrlLauncherLinkOpener implements LinkOpener {
  const UrlLauncherLinkOpener();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
