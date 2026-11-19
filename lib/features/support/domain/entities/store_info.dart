import 'package:equatable/equatable.dart';

/// A way to reach the store.
enum ContactChannel { whatsapp, email, phone }

/// A social network the store is on.
enum SocialNetwork {
  facebook,
  instagram,
  x,
  tiktok,
  snapchat,
  youtube,
  linkedin,
}

/// How to reach the store and where it is online (from the site settings).
/// Anything the store did not set is null.
class StoreInfo extends Equatable {
  const StoreInfo({
    this.whatsappNumber,
    this.email,
    this.phone,
    this.social = const {},
  });

  /// International digits, no `+`.
  final String? whatsappNumber;
  final String? email;
  final String? phone;

  /// Profile links, `https://...`.
  final Map<SocialNetwork, String> social;

  bool has(ContactChannel channel) => switch (channel) {
    ContactChannel.whatsapp => whatsappNumber != null,
    ContactChannel.email => email != null,
    ContactChannel.phone => phone != null,
  };

  /// The link that opens [channel]: a WhatsApp chat, a new e-mail or a call.
  /// Null when the store has not set it.
  Uri? contactUri(ContactChannel channel) => switch (channel) {
    ContactChannel.whatsapp =>
      whatsappNumber == null ? null : Uri.https('wa.me', '/$whatsappNumber'),
    ContactChannel.email =>
      email == null ? null : Uri(scheme: 'mailto', path: email),
    ContactChannel.phone =>
      phone == null ? null : Uri(scheme: 'tel', path: phone),
  };

  Uri? socialUri(SocialNetwork network) {
    final link = social[network];
    return link == null ? null : Uri.tryParse(link);
  }

  @override
  List<Object?> get props => [whatsappNumber, email, phone, social];
}
