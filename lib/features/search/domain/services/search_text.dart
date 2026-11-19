/// How search texts are compared. Arabic is typed in many spellings of the
/// same word (أ / إ / آ / ا, ى / ي, ة / ه, with or without diacritics), so
/// both the query and the candidates are folded to one form first.
abstract final class SearchText {
  static final RegExp _diacritics = RegExp('[ً-ٰٟـ]');
  static final RegExp _spaces = RegExp(r'\s+');

  /// [text] in lower case, without diacritics and with the Arabic letter
  /// variants folded together.
  static String normalize(String text) {
    var folded = text.toLowerCase().replaceAll(_diacritics, '');
    const map = {
      'أ': 'ا',
      'إ': 'ا',
      'آ': 'ا',
      'ى': 'ي',
      'ة': 'ه',
      'ؤ': 'و',
      'ئ': 'ي',
    };
    map.forEach((from, to) => folded = folded.replaceAll(from, to));
    return folded.replaceAll(_spaces, ' ').trim();
  }

  /// True when every word of [query] starts a word of [candidate] or is
  /// inside one: "vit d" finds "Vitamin D3".
  static bool matches(String candidate, String query) {
    final text = normalize(candidate);
    final words = normalize(query).split(' ').where((w) => w.isNotEmpty);
    if (words.isEmpty) return false;
    return words.every(text.contains);
  }

  /// 0 when [candidate] starts with [query], 1 when a word of it does,
  /// 2 otherwise: the order suggestions are shown in.
  static int rank(String candidate, String query) {
    final text = normalize(candidate);
    final q = normalize(query);
    if (text.startsWith(q)) return 0;
    if (text.contains(' $q')) return 1;
    return 2;
  }
}
