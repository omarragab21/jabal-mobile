import '../../domain/entities/phone_number.dart';

/// Route arguments of the verification screen.
class OtpArgs {
  const OtpArgs({required this.phone});
  final PhoneNumber phone;
}
