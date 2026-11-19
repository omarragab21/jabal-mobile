import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/ask_cards.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_grid.dart';
import '../widgets/home_search_field.dart';
import '../widgets/news_ticker.dart';
import '../widgets/product_tile.dart';
import '../widgets/product_section.dart';

/// Home tab: delivery address and product search on top, then the news bar,
/// banners, the two "ask" shortcuts, the categories and a product row per
/// category. Typing in the search box swaps the content for the results.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.animations = true,
    this.onOpenCategories,
    this.onOpenCategory,
    this.onOpenProduct,
    this.onOpenSearch,
    this.deliveryHeaderBuilder,
  });

  /// False stops the news bar and the banner auto-play (tests).
  final bool animations;

  /// "All categories" tile.
  final VoidCallback? onOpenCategories;

  /// A category tile or a section arrow.
  final ValueChanged<ProductCategory>? onOpenCategory;

  /// A product card was tapped.
  final ProductOpener? onOpenProduct;

  /// The search field was tapped: open the search screen.
  final VoidCallback? onOpenSearch;

  /// Builds the delivery address line with the given widget (the search
  /// field) under it. Without it the search field stands alone.
  final Widget Function(Widget below)? deliveryHeaderBuilder;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // First build, and again whenever the app language changes.
    final code = context.locale.languageCode;
    if (code != _languageCode) {
      _languageCode = code;
      context.read<HomeCubit>().load(code);
    }
  }

  String _t(String key) => 'home.$key'.tr(context: context);

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// Opens WhatsApp with the support team and a ready-made [messageKey].
  Future<void> _askSupport(String messageKey) async {
    final opened = await context.read<HomeCubit>().contactSupport(
      _t(messageKey),
    );
    if (!opened && mounted) _toast(_t('whatsapp_failed'));
  }

  Widget _card(Product product) {
    final cubit = context.read<HomeCubit>();
    return ProductTile(
      key: ValueKey('product-${product.id}'),
      product: product,
      onTap: () => widget.onOpenProduct?.call(context, product),
      onAddToCart: () async {
        await cubit.addToCart(product);
        if (mounted) showAddedToCart(context, product);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                child: Builder(
                  builder: (context) {
                    // The field only opens the search screen.
                    final search = HomeSearchField(
                      readOnly: true,
                      onTap: widget.onOpenSearch,
                      hint: _t('search_hint'),
                      clearLabel: _t('clear_search'),
                    );
                    return widget.deliveryHeaderBuilder?.call(search) ?? search;
                  },
                ),
              ),
              Expanded(child: _homeBody(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _message(String text, {String? actionLabel, VoidCallback? onAction}) =>
      Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (actionLabel != null) ...[
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel,
                    style: AppTextStyles.textMdBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

  Widget _loader() =>
      const Center(child: CircularProgressIndicator(color: AppColors.primary));

  Widget _homeBody(HomeState state) {
    final cubit = context.read<HomeCubit>();
    if (state.status == HomeStatus.loading) return _loader();
    if (state.status == HomeStatus.failed) {
      return _message(
        _t('error'),
        actionLabel: _t('retry'),
        onAction: () => cubit.load(_languageCode ?? 'ar'),
      );
    }
    final data = state.data;
    final side = EdgeInsets.symmetric(horizontal: 16.w);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: cubit.refresh,
      child: ListView(
        padding: EdgeInsets.only(bottom: 24.h),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          NewsTicker(
            items: [for (final item in data.news) item.text],
            animate: widget.animations,
          ),
          if (data.banners.isNotEmpty) ...[
            SizedBox(height: 16.h),
            BannerCarousel(banners: data.banners, autoPlay: widget.animations),
          ],
          SizedBox(height: 16.h),
          Padding(
            padding: side,
            child: AskCardsRow(
              pharmacistLabel: _t('ask_pharmacist'),
              beauticianLabel: _t('ask_beautician'),
              onPharmacist: () => _askSupport('ask_pharmacist_message'),
              onBeautician: () => _askSupport('ask_beautician_message'),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: side,
            child: CategoryGrid(
              tiles: [
                CategoryTileData(
                  label: _t('all_categories'),
                  imageAsset: 'assets/images/home/all_categories.png',
                  onTap: widget.onOpenCategories,
                ),
                for (final category in data.categories)
                  CategoryTileData(
                    label: category.name,
                    imageUrl: category.imageUrl,
                    onTap: () => widget.onOpenCategory?.call(category),
                  ),
              ],
            ),
          ),
          for (final section in data.sections) ...[
            SizedBox(height: 24.h),
            ProductSection(
              title: section.title,
              seeAllLabel: _t('see_all'),
              onSeeAll: () => widget.onOpenCategory?.call(section.category),
              cards: [for (final p in section.products) _card(p)],
            ),
          ],
        ],
      ),
    );
  }
}
