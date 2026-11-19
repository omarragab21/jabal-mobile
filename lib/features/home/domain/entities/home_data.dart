import 'package:equatable/equatable.dart';

import 'home_banner.dart';
import 'home_section.dart';
import 'news_item.dart';
import 'product.dart';
import 'product_category.dart';

/// Everything the home page shows, in one immutable snapshot.
class HomeData extends Equatable {
  const HomeData({
    this.news = const [],
    this.banners = const [],
    this.categories = const [],
    this.sections = const [],
  });

  final List<NewsItem> news;
  final List<HomeBanner> banners;
  final List<ProductCategory> categories;
  final List<HomeSection> sections;

  /// Groups [products] under their category (a product of a sub-category
  /// belongs to its parent too), keeping the order of [categories] and
  /// dropping categories without products.
  static List<HomeSection> sectionsOf(
    List<ProductCategory> categories,
    List<Product> products,
  ) => [
    for (final category in categories)
      if (products.any((p) => category.allIds.contains(p.categoryId)))
        HomeSection(
          category: category,
          products: [
            for (final p in products)
              if (category.allIds.contains(p.categoryId)) p,
          ],
        ),
  ];

  @override
  List<Object?> get props => [news, banners, categories, sections];
}
