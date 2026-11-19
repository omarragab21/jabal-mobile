import 'package:equatable/equatable.dart';

/// A country the user can pick a phone dial code for.
class Country extends Equatable {
  const Country({
    required this.isoCode,
    required this.dialCode,
    required this.nameAr,
    required this.nameEn,
  });

  /// ISO 3166-1 alpha-2, e.g. `JO`.
  final String isoCode;

  /// Dial code digits without `+`, e.g. `962`.
  final String dialCode;
  final String nameAr;
  final String nameEn;

  String get dialCodeWithPlus => '+$dialCode';

  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  @override
  List<Object?> get props => [isoCode];
}
