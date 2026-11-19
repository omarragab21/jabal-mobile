import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/support_contact.dart';

/// [SupportContact] read from the site settings (`GET /v1/site/settings`).
abstract final class SupportContactModel {
  /// The `whatsapp` setting is a link (`https://wa.me/966500000000`) or just
  /// the number. Returns null when it holds no usable number.
  static SupportContact? tryFromSettings(Map<String, dynamic> settings) {
    final raw = JsonReader.string(settings['whatsapp']);
    final fromLink =
        RegExp(r'wa\.me/\+?(\d+)').firstMatch(raw)?.group(1) ??
        RegExp(r'[?&]phone=\+?(\d+)').firstMatch(raw)?.group(1);
    final digits = fromLink ?? raw.replaceAll(RegExp(r'[\s+()-]'), '');
    // E.164: 8 to 15 digits.
    if (!RegExp(r'^\d{8,15}$').hasMatch(digits)) return null;
    return SupportContact(whatsappNumber: digits);
  }
}
