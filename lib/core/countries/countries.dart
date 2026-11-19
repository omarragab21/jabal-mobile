import 'countries_data.dart';
import 'country.dart';

export 'countries_data.dart';
export 'country.dart';

/// Arab League members — the only countries offered for now.
const Set<String> kArabCountryCodes = {
  'JO',
  'SA',
  'EG',
  'AE',
  'BH',
  'DZ',
  'DJ',
  'IQ',
  'KM',
  'KW',
  'LB',
  'LY',
  'MA',
  'MR',
  'OM',
  'PS',
  'QA',
  'SD',
  'SO',
  'SY',
  'TN',
  'YE',
};

/// Temporary scope: set to `false` to offer every country in
/// [kCountries] (all of them are validated through the same phone rules).
const bool kArabCountriesOnly = true;

abstract final class Countries {
  /// Countries the user can pick right now (Jordan, Saudi Arabia, Egypt first).
  static final List<Country> available = kArabCountriesOnly
      ? kCountries.where((c) => kArabCountryCodes.contains(c.isoCode)).toList()
      : kCountries;

  /// Default country (Jordan, the first design).
  static Country get defaultCountry => kCountries.first;

  /// Looks up in the full list so a saved country keeps working if the scope
  /// widens or narrows.
  static Country byIso(String iso) => kCountries.firstWhere(
    (c) => c.isoCode == iso.toUpperCase(),
    orElse: () => defaultCountry,
  );

  /// Case-insensitive search by name (either language) or dial code.
  static List<Country> search(String query) {
    final q = query.trim().toLowerCase().replaceFirst('+', '');
    if (q.isEmpty) return available;
    return available
        .where(
          (c) =>
              c.nameAr.contains(q) ||
              c.nameEn.toLowerCase().contains(q) ||
              c.dialCode.startsWith(q),
        )
        .toList();
  }
}
