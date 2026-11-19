/// Tolerant readers for decoded JSON. The backend is loose with types (a
/// number may arrive as `"6.5"`, an empty map as `[]`), so models read every
/// field through these instead of casting.
abstract final class JsonReader {
  static Map<String, dynamic> map(Object? value) =>
      value is Map ? value.cast<String, dynamic>() : const {};

  static List<Map<String, dynamic>> mapList(Object? value) => value is List
      ? [
          for (final item in value)
            if (item is Map) item.cast<String, dynamic>(),
        ]
      : const [];

  static String string(Object? value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static String? stringOrNull(Object? value) {
    final text = string(value);
    return text.isEmpty ? null : text;
  }

  static int integer(Object? value, [int fallback = 0]) => switch (value) {
    final int v => v,
    final num v => v.toInt(),
    final String v => int.tryParse(v.trim()) ?? fallback,
    _ => fallback,
  };

  static double decimal(Object? value, [double fallback = 0]) =>
      decimalOrNull(value) ?? fallback;

  static double? decimalOrNull(Object? value) => switch (value) {
    final num v => v.toDouble(),
    final String v => double.tryParse(v.trim()),
    _ => null,
  };

  static bool boolean(Object? value, [bool fallback = false]) =>
      switch (value) {
        final bool v => v,
        final num v => v != 0,
        final String v => switch (v.trim().toLowerCase()) {
          '1' || 'true' => true,
          '0' || 'false' || '' => false,
          _ => fallback,
        },
        _ => fallback,
      };

  /// The API's `translations: {ar: {...}, en: {...}}` value of [field] in
  /// [languageCode]; falls back to the top-level field, then the other
  /// language.
  static String translated(
    Map<String, dynamic> json,
    String field,
    String languageCode,
  ) {
    final translations = map(json['translations']);
    final wanted = stringOrNull(map(translations[languageCode])[field]);
    if (wanted != null) return wanted;
    final top = stringOrNull(json[field]);
    if (top != null) return top;
    for (final other in translations.values) {
      final text = stringOrNull(map(other)[field]);
      if (text != null) return text;
    }
    return '';
  }
}
