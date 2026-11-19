import 'package:equatable/equatable.dart';

/// How to reach the store's support team.
class SupportContact extends Equatable {
  const SupportContact({required this.whatsappNumber})
    : assert(whatsappNumber != '');

  /// International format, digits only, no `+` (`962791234567`).
  final String whatsappNumber;

  /// A WhatsApp chat with the support number; [message] is typed in the
  /// message box, ready to send.
  Uri whatsappChat(String message) => Uri.https(
    'wa.me',
    '/$whatsappNumber',
    message.isEmpty ? null : {'text': message},
  );

  @override
  List<Object?> get props => [whatsappNumber];
}
