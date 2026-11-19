import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/store_info.dart';

/// [StoreInfo] read from the site settings (`GET /v1/site/settings`).
abstract final class StoreInfoModel {
  static StoreInfo fromSettings(Map<String, dynamic> settings) {
    final social = JsonReader.map(settings['social_links']);
    String? link(String key) {
      final text = JsonReader.stringOrNull(social[key] ?? settings[key]);
      final uri = text == null ? null : Uri.tryParse(text);
      return uri != null && uri.hasScheme && uri.host.isNotEmpty ? text : null;
    }

    return StoreInfo(
      whatsappNumber: _whatsappNumber(settings['whatsapp']),
      email: _email(
        JsonReader.stringOrNull(settings['support_email'] ?? settings['email']),
      ),
      phone: _phone(
        JsonReader.stringOrNull(
          settings['support_phone'] ?? settings['site_contact_phone'],
        ),
      ),
      social: {
        for (final (network, key) in const [
          (SocialNetwork.facebook, 'facebook'),
          (SocialNetwork.instagram, 'instagram'),
          (SocialNetwork.x, 'x_twitter'),
          (SocialNetwork.tiktok, 'tiktok'),
          (SocialNetwork.snapchat, 'snapchat'),
          (SocialNetwork.youtube, 'youtube'),
          (SocialNetwork.linkedin, 'linkedin'),
        ])
          network: ?link(key),
      },
    );
  }

  /// `https://wa.me/966500000000`, a `phone=` link or plain digits.
  static String? _whatsappNumber(Object? value) {
    final raw = JsonReader.string(value);
    final digits =
        RegExp(r'wa\.me/\+?(\d+)').firstMatch(raw)?.group(1) ??
        RegExp(r'[?&]phone=\+?(\d+)').firstMatch(raw)?.group(1) ??
        raw.replaceAll(RegExp(r'[\s+()-]'), '');
    return RegExp(r'^\d{8,15}$').hasMatch(digits) ? digits : null;
  }

  static String? _email(String? value) =>
      value != null && RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)
      ? value
      : null;

  static String? _phone(String? value) {
    final cleaned = value?.replaceAll(RegExp(r'[\s()-]'), '');
    return cleaned != null && RegExp(r'^\+?\d{5,15}$').hasMatch(cleaned)
        ? cleaned
        : null;
  }
}
