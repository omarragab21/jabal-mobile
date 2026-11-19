import 'package:equatable/equatable.dart';

/// The text for a point on the map: a short [headline] (street) and the
/// rest ([details]: area, city), as in the address card of the map page.
class PlaceInfo extends Equatable {
  const PlaceInfo({required this.headline, this.details = ''});

  final String headline;
  final String details;

  /// Splits a geocoder's formatted address at its first comma (Arabic `،` or
  /// Latin `,`): `شارع الدفاع، إربد، الأردن` -> headline `شارع الدفاع`.
  factory PlaceInfo.fromFormatted(String formatted) {
    final text = formatted.trim();
    final cut = text.indexOf(RegExp('[،,]'));
    if (cut < 0) return PlaceInfo(headline: text);
    return PlaceInfo(
      headline: text.substring(0, cut).trim(),
      details: text.substring(cut + 1).trim(),
    );
  }

  /// `headline، details`, or just the headline when there are no details.
  String get fullText => details.isEmpty ? headline : '$headline، $details';

  @override
  List<Object?> get props => [headline, details];
}
