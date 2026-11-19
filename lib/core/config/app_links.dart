/// Web addresses of the app itself. These are placeholders until the store
/// listings exist: replace them here, nothing else needs to change.
abstract final class AppLinks {
  /// Where friends are sent to download the app.
  static const String download = 'https://drjabel.app/download';

  static const String appStore = 'https://apps.apple.com/app/dr-jabel';

  static const String playStore =
      'https://play.google.com/store/apps/details?id=com.bekite.drjabel';

  /// The page of one product, what a shared product link opens.
  static Uri product(int id) => Uri.https('drjabel.app', '/product/$id');
}
