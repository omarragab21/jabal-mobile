/// Turns Arabic-Indic (٠-٩) and Persian (۰-۹) digits into 0-9 so a user with
/// an Arabic keyboard is validated (and stored) the same as everyone else.
abstract final class DigitNormalizer {
  static String toLatin(String input) {
    final out = StringBuffer();
    for (final r in input.runes) {
      if (r >= 0x0660 && r <= 0x0669) {
        out.writeCharCode(r - 0x0660 + 0x30);
      } else if (r >= 0x06F0 && r <= 0x06F9) {
        out.writeCharCode(r - 0x06F0 + 0x30);
      } else {
        out.writeCharCode(r);
      }
    }
    return out.toString();
  }

  /// Latin digits only.
  static String digitsOnly(String input) =>
      toLatin(input).replaceAll(RegExp(r'\D'), '');
}
