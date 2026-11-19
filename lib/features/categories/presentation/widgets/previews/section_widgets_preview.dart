import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../../core/widgets/previews/preview_wrapper.dart';
import '../section_tile.dart';

// Run with:  flutter widget-preview start

Widget _grid(List<(String, String)> items) => SectionsGrid(
  tiles: [
    for (final (name, image) in items)
      SectionTile(name: name, imageUrl: 'assets/images/sections/$image.jpg'),
  ],
);

@Preview(
  group: 'Sections / Tile',
  name: 'Single line (AR)',
  size: Size(200, 150),
  wrapper: rtlWrapper,
)
Widget tileArabic() => const SizedBox(
  width: 160,
  child: SectionTile(
    name: 'العناية بالبشرة',
    imageUrl: 'assets/images/sections/skin.jpg',
  ),
);

@Preview(
  group: 'Sections / Tile',
  name: 'Two lines (AR)',
  size: Size(200, 150),
  wrapper: rtlWrapper,
)
Widget tileTwoLines() => const SizedBox(
  width: 160,
  child: SectionTile(
    name: 'الفيتامينات والمكملات',
    imageUrl: 'assets/images/sections/vitamins.jpg',
  ),
);

@Preview(
  group: 'Sections / Tile',
  name: 'Two lines (EN)',
  size: Size(200, 150),
  wrapper: ltrWrapper,
)
Widget tileEnglish() => const SizedBox(
  width: 160,
  child: SectionTile(
    name: 'Vitamins & supplements',
    imageUrl: 'assets/images/sections/vitamins.jpg',
  ),
);

@Preview(
  group: 'Sections / Grid',
  name: 'Four rows (AR)',
  size: Size(375, 560),
  wrapper: rtlWrapper,
)
Widget gridArabic() => _grid(const [
  ('الفيتامينات والمكملات', 'vitamins'),
  ('الأدوية العلاجية', 'medicines'),
  ('العناية بالشعر', 'hair'),
  ('العناية بالبشرة', 'skin'),
  ('الأجهزة والمستلزمات', 'devices'),
  ('الأم والطفل', 'mother_baby'),
  ('رعاية كبار السن', 'elderly'),
  ('الإسعافات الأولية', 'first_aid'),
]);

@Preview(
  group: 'Sections / Grid',
  name: 'Four rows (EN)',
  size: Size(375, 560),
  wrapper: ltrWrapper,
)
Widget gridEnglish() => _grid(const [
  ('Vitamins & supplements', 'vitamins'),
  ('Medicines', 'medicines'),
  ('Hair care', 'hair'),
  ('Skin care', 'skin'),
  ('Devices & supplies', 'devices'),
  ('Mother & baby', 'mother_baby'),
  ('Elderly care', 'elderly'),
  ('First aid', 'first_aid'),
]);
