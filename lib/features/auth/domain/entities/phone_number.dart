import 'package:equatable/equatable.dart';

import '../validators/digit_normalizer.dart';

/// A phone number: the country it belongs to plus the national part exactly as
/// typed (a leading trunk `0` is allowed). Arabic-Indic digits are accepted.
class PhoneNumber extends Equatable {
  const PhoneNumber({
    required this.isoCode,
    required this.dialCode,
    required this.national,
  });

  /// ISO 3166-1 alpha-2 of the country (`JO`) — used to validate the number.
  final String isoCode;

  /// Dial code digits without `+` (e.g. `962`).
  final String dialCode;
  final String national;

  /// National digits only (Latin), without the leading trunk zero(s).
  String get nationalDigits =>
      DigitNormalizer.digitsOnly(national).replaceFirst(RegExp(r'^0+'), '');

  /// `+962791234567`
  String get e164 => '+$dialCode$nationalDigits';

  /// Local display with the trunk zero, e.g. `0791234567`.
  String get local => '0$nationalDigits';

  @override
  List<Object?> get props => [isoCode, dialCode, nationalDigits];
}
