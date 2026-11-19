import '../platform/clipboard_writer.dart';
import '../platform/link_opener.dart';
import 'share_target.dart';

/// Sends a link ([message] + [link]) to a [ShareTarget]: a product page, the
/// app's download page. One implementation for everything that shares.
class ShareLink {
  const ShareLink(this._opener, this._clipboard);

  final LinkOpener _opener;
  final ClipboardWriter _clipboard;

  /// The address that shares to [target]; null for targets that have none
  /// (copy link) or need the link on the clipboard first (Instagram).
  static Uri? shareUri(ShareTarget target, String message, Uri link) {
    final text = '$message $link';
    return switch (target) {
      ShareTarget.whatsapp => Uri.https('wa.me', '/', {'text': text}),
      ShareTarget.facebook => Uri.https(
        'www.facebook.com',
        '/sharer/sharer.php',
        {'u': '$link'},
      ),
      ShareTarget.messenger => Uri(
        scheme: 'fb-messenger',
        host: 'share',
        queryParameters: {'link': '$link'},
      ),
      ShareTarget.snapchat => Uri.https('www.snapchat.com', '/scan', {
        'attachmentUrl': '$link',
      }),
      ShareTarget.x => Uri.https('twitter.com', '/intent/tweet', {
        'text': message,
        'url': '$link',
      }),
      // The system messaging composer: a way out for "more" without a native
      // share-sheet plugin.
      ShareTarget.more => Uri(scheme: 'sms', queryParameters: {'body': text}),
      ShareTarget.instagram || ShareTarget.copyLink => null,
    };
  }

  Future<ShareOutcome> call(
    ShareTarget target, {
    required String message,
    required Uri link,
  }) async {
    switch (target) {
      case ShareTarget.copyLink:
        await _clipboard.copy('$link');
        return ShareOutcome.copied;
      case ShareTarget.instagram:
        // Instagram has no share address: copy the link, open the app.
        await _clipboard.copy('$link');
        await _opener.open(Uri(scheme: 'instagram', host: 'app'));
        return ShareOutcome.copied;
      default:
        final opened = await _opener.open(shareUri(target, message, link)!);
        return opened ? ShareOutcome.opened : ShareOutcome.failed;
    }
  }
}
