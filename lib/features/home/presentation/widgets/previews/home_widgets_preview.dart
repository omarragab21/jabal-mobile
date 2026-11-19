import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../../core/widgets/previews/preview_wrapper.dart';
import '../../../domain/entities/home_banner.dart';
import '../../../domain/entities/product.dart';
import '../ask_cards.dart';
import '../banner_carousel.dart';
import '../category_chips.dart';
import '../category_grid.dart';
import '../home_search_field.dart';
import '../news_ticker.dart';
import '../product_card.dart';
import '../product_section.dart';

// Run with:  flutter widget-preview start

const _storage = 'https://backend-jabal.be-kite.com/public/storage';

Product _product({bool arabic = true, bool discount = true}) => Product(
  id: 101,
  name: arabic ? 'بخاخ محلول ملحي' : 'Saline nasal spray',
  categoryId: 68,
  categoryName: arabic ? 'العناية بالأنف' : 'Nasal care',
  price: 5,
  finalPrice: discount ? 4.25 : 5,
  imageUrl: '$_storage/products/85d893eb-d82d-4659-ad8e-2a1ab668d10d.png',
  attributes: [
    ProductAttribute(
      name: arabic ? 'الحجم' : 'Size',
      values: [ProductAttributeValue(id: 1, name: arabic ? '30 مل' : '30 ml')],
    ),
  ],
  stock: 10,
);

Widget _card({
  bool arabic = true,
  bool discount = true,
  bool favorite = false,
}) => SizedBox(
  width: 160,
  child: ProductCard(
    product: _product(arabic: arabic, discount: discount),
    currency: arabic ? 'د.أ' : 'JOD',
    addToCartLabel: arabic ? 'أضف للسلة' : 'Add to cart',
    favoriteLabel: arabic ? 'إضافة إلى المفضلة' : 'Add to favourites',
    isFavorite: favorite,
    onFavorite: () {},
    onAddToCart: () {},
  ),
);

@Preview(
  group: 'Home / Product card',
  name: 'Discount (AR)',
  wrapper: rtlWrapper,
)
Widget productCardArabic() => _card();

@Preview(
  group: 'Home / Product card',
  name: 'No discount, favourite (AR)',
  wrapper: rtlWrapper,
)
Widget productCardFavorite() => _card(discount: false, favorite: true);

@Preview(
  group: 'Home / Product card',
  name: 'Discount (EN)',
  wrapper: ltrWrapper,
)
Widget productCardEnglish() => _card(arabic: false);

@Preview(
  group: 'Home / Search field',
  name: 'Empty (AR)',
  size: Size(375, 70),
  wrapper: rtlWrapper,
)
Widget searchArabic() => HomeSearchField(
  controller: TextEditingController(),
  hint: 'ابحث عن منتج ...',
  clearLabel: 'مسح البحث',
);

@Preview(
  group: 'Home / Search field',
  name: 'Typed (EN)',
  size: Size(375, 70),
  wrapper: ltrWrapper,
)
Widget searchEnglish() => HomeSearchField(
  controller: TextEditingController(text: 'vitamin'),
  hint: 'Search for a product ...',
  clearLabel: 'Clear search',
);

@Preview(
  group: 'Home / News ticker',
  name: 'Running (AR)',
  size: Size(375, 80),
  wrapper: rtlWrapper,
)
Widget tickerArabic() => const NewsTicker(
  items: [
    'صيدليات الجبل.. النصيحة بجبل، صحتكم أولويتنا دائماً.',
    'اكتشفوا مجموعة واسعة من منتجات العناية بالبشرة والشعر.',
  ],
);

@Preview(
  group: 'Home / News ticker',
  name: 'Running (EN)',
  size: Size(375, 80),
  wrapper: ltrWrapper,
)
Widget tickerEnglish() => const NewsTicker(
  items: [
    'Al-Jabal Pharmacies: advice you can lean on.',
    'Discover a wide range of skin and hair care products.',
  ],
);

@Preview(
  group: 'Home / Banners',
  name: 'Carousel',
  size: Size(375, 220),
  wrapper: rtlWrapper,
)
Widget banners() => const BannerCarousel(
  autoPlay: false,
  banners: [
    HomeBanner(
      id: 1,
      imageUrl:
          '$_storage/sliders/slider_3b8cb414-18db-452e-8fc3-b0085befb7f2_1793801245.png',
    ),
    HomeBanner(
      id: 2,
      imageUrl:
          '$_storage/sliders/slider_ab990ba2-3fe0-4a04-97da-ba57108cbdb3_1793803064.png',
    ),
  ],
);

@Preview(
  group: 'Home / Ask cards',
  name: 'Arabic',
  size: Size(375, 150),
  wrapper: rtlWrapper,
)
Widget askArabic() => const AskCardsRow(
  pharmacistLabel: 'اسأل الصيدلي',
  beauticianLabel: 'اسأل اخصائي التجميل',
);

@Preview(
  group: 'Home / Ask cards',
  name: 'English',
  size: Size(375, 150),
  wrapper: ltrWrapper,
)
Widget askEnglish() => const AskCardsRow(
  pharmacistLabel: 'Ask the pharmacist',
  beauticianLabel: 'Ask a beauty specialist',
);

const _allAsset = 'assets/images/home/all_categories.png';

@Preview(
  group: 'Home / Categories',
  name: 'Grid (AR)',
  size: Size(375, 300),
  wrapper: rtlWrapper,
)
Widget categoriesArabic() => const CategoryGrid(
  tiles: [
    CategoryTileData(label: 'كل الفئات', imageAsset: _allAsset),
    CategoryTileData(label: 'عروض حصرية'),
    CategoryTileData(label: 'العناية بالأم والطفل'),
    CategoryTileData(label: 'العناية بالفم والأسنان'),
    CategoryTileData(label: 'الفيتامينات'),
    CategoryTileData(label: 'العناية بالشعر'),
  ],
);

@Preview(
  group: 'Home / Categories',
  name: 'Grid (EN)',
  size: Size(375, 300),
  wrapper: ltrWrapper,
)
Widget categoriesEnglish() => const CategoryGrid(
  tiles: [
    CategoryTileData(label: 'All categories', imageAsset: _allAsset),
    CategoryTileData(label: 'Exclusive offers'),
    CategoryTileData(label: 'Mother & baby care'),
    CategoryTileData(label: 'Oral & dental care'),
    CategoryTileData(label: 'Vitamins'),
  ],
);

@Preview(
  group: 'Home / Section',
  name: 'Header (AR)',
  size: Size(375, 60),
  wrapper: rtlWrapper,
)
Widget sectionHeaderArabic() =>
    const SectionHeader(title: 'العناية بالأنف', seeAllLabel: 'عرض الكل');

@Preview(
  group: 'Home / Section',
  name: 'Header (EN)',
  size: Size(375, 60),
  wrapper: ltrWrapper,
)
Widget sectionHeaderEnglish() =>
    const SectionHeader(title: 'Nasal care', seeAllLabel: 'See all');

@Preview(
  group: 'Home / Category chips',
  name: 'Chips (AR)',
  size: Size(375, 70),
  wrapper: rtlWrapper,
)
Widget chipsArabic() => const CategoryChips(
  allLabel: 'الكل',
  labels: ['الفئة الفرعية المرتبطة', 'أوميغا 3', 'فيتامين سي', 'المعادن'],
);

@Preview(
  group: 'Home / Category chips',
  name: 'Chips (EN)',
  size: Size(375, 70),
  wrapper: ltrWrapper,
)
Widget chipsEnglish() => const CategoryChips(
  allLabel: 'All',
  labels: ['Omega-3', 'Vitamin C', 'Vitamins & supplements', 'Minerals'],
);
