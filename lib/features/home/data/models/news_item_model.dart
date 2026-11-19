import 'dart:convert';

import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/news_item.dart';

/// [NewsItem] parsed from the `news_bar_items` setting:
/// `{id, text_ar, text_en, is_active}`.
class NewsItemModel extends NewsItem {
  const NewsItemModel({required super.id, required super.text});

  /// The active, non-empty items of the setting in [languageCode]; an item
  /// missing that language falls back to the other one. The setting may be a
  /// list or a JSON string of one.
  static List<NewsItemModel> listFromSetting(
    Object? setting,
    String languageCode,
  ) {
    Object? raw = setting;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } on FormatException {
        return const [];
      }
    }
    final (first, second) = languageCode == 'ar'
        ? ('text_ar', 'text_en')
        : ('text_en', 'text_ar');
    final items = JsonReader.mapList(raw);
    return [
      for (var i = 0; i < items.length; i++)
        if (JsonReader.boolean(items[i]['is_active'], true))
          if (JsonReader.stringOrNull(items[i][first]) ??
                  JsonReader.stringOrNull(items[i][second])
              case final text?)
            NewsItemModel(
              id: JsonReader.string(items[i]['id'], 'news-$i'),
              text: text,
            ),
    ];
  }
}
