import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/images/app_image_cache.dart';
import '../../../../core/sharing/share_flow.dart';
import '../../../../core/sharing/share_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/count_badge.dart';
import '../../../home/presentation/cubit/favorites_cubit.dart';
import '../../domain/entities/product_details.dart';
import '../cubit/product_details_cubit.dart';
import '../widgets/add_to_cart_bar.dart';
import '../widgets/page_dots.dart';
import '../widgets/round_icon_button.dart';
import '../widgets/viewers_chip.dart';
import 'image_preview_page.dart';

/// A product's page: pictures with the floating actions, the name, price and
/// description, and the bar to choose a quantity and add it to the cart (or
/// update the cart line it was opened from).
class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
    required this.onOpenCart,
    required this.onOpenCategory,
  });

  /// The cart button was tapped; gets this page's context to navigate with.
  final ValueChanged<BuildContext> onOpenCart;

  /// The category name was tapped: open that category.
  final void Function(BuildContext context, int categoryId) onOpenCategory;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String? _languageCode;
  final PageController _pages = PageController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = context.locale.languageCode;
    if (code != _languageCode) {
      _languageCode = code;
      context.read<ProductDetailsCubit>().load(code);
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  String _t(String key) => 'product_details.$key'.tr(context: context);

  Future<void> _submit(ProductDetailsCubit cubit) async {
    final update = cubit.args.isUpdate;
    final done = await cubit.submit();
    if (!mounted) return;
    showAppToast(
      context,
      done
          ? _t(update ? 'cart_updated' : 'added_to_cart')
          : _t('submit_failed'),
      error: !done,
    );
    if (done && update) Navigator.of(context).pop(cubit.state.quantity);
  }

  Future<void> _share(ProductDetailsCubit cubit, ProductDetails product) async {
    final target = await showShareSheet(context, title: _t('share_title'));
    if (target == null || !mounted) return;
    final outcome = await cubit.share(
      target,
      'product_details.share_message'.tr(
        context: context,
        namedArgs: {'name': product.name},
      ),
    );
    if (mounted) showShareFeedback(context, outcome);
  }

  void _preview(ProductDetails product, int index) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) =>
              ImagePreviewPage(images: product.images, initialIndex: index),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductDetailsCubit>();
    return BlocListener<ProductDetailsCubit, ProductDetailsState>(
      // The pictures the carousel has not shown yet start downloading now,
      // so a swipe finds them ready.
      listenWhen: (p, c) => p.product?.id != c.product?.id && c.product != null,
      listener: (context, state) =>
          AppImageCacheManager.precache(context, state.product!.images),
      child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          final product = state.product;
          if (state.status == ProductDetailsStatus.loading || product == null) {
            return AppSubPage(
              title: '',
              backgroundColor: AppColors.backgroundBody,
              body: state.status == ProductDetailsStatus.failed
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _t('error'),
                            style: AppTextStyles.textMdRegular.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => cubit.load(_languageCode ?? 'ar'),
                            child: Text('home.retry'.tr(context: context)),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
            );
          }
          return Scaffold(
            backgroundColor: AppColors.backgroundBody,
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Gallery(
                          product: product,
                          controller: _pages,
                          cartCount: state.cartCount,
                          onPageChanged: cubit.selectImage,
                          onOpenImage: () =>
                              _preview(product, state.imageIndex),
                          onBack: () => Navigator.of(context).maybePop(),
                          onShare: () => _share(cubit, product),
                          onCart: () => widget.onOpenCart(context),
                          backLabel: _t('back'),
                          shareLabel: _t('share'),
                          cartLabel: _t('cart'),
                        ),
                        SizedBox(height: 12.h),
                        PageDots(
                          count: product.images.length,
                          index: state.imageIndex,
                        ),
                        _Info(
                          product: product,
                          onOpenCategory: () => widget.onOpenCategory(
                            context,
                            product.categoryId,
                          ),
                          detailsTitle: _t('details_title'),
                        ),
                      ],
                    ),
                  ),
                ),
                AddToCartBar(
                  quantity: state.quantity,
                  onDecrement: state.canDecrement ? cubit.decrement : null,
                  onIncrement: state.canIncrement ? cubit.increment : null,
                  decrementLabel: _t('decrease'),
                  incrementLabel: _t('increase'),
                  label: !product.inStock
                      ? _t('out_of_stock')
                      : _t(cubit.args.isUpdate ? 'update' : 'add_to_cart'),
                  total: product.inStock
                      ? '${state.total.toStringAsFixed(2)} ${'home.currency'.tr(context: context)}'
                      : null,
                  onPressed: product.inStock && !state.submitting
                      ? () => _submit(cubit)
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The picture area: swipeable pictures under the floating buttons, with the
/// "viewing now" tab on its bottom edge.
class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.product,
    required this.controller,
    required this.cartCount,
    required this.onPageChanged,
    required this.onOpenImage,
    required this.onBack,
    required this.onShare,
    required this.onCart,
    required this.backLabel,
    required this.shareLabel,
    required this.cartLabel,
  });

  final ProductDetails product;
  final PageController controller;
  final int cartCount;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onOpenImage;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onCart;
  final String backLabel;
  final String shareLabel;
  final String cartLabel;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      height: 456.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: controller,
            itemCount: product.images.isEmpty ? 1 : product.images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (_, i) => GestureDetector(
              onTap: product.images.isEmpty ? null : onOpenImage,
              child: AppNetworkImage(
                url: product.images.isEmpty ? null : product.images[i],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  children: [
                    RoundIconButton(
                      key: const ValueKey('product-back'),
                      label: backLabel,
                      onTap: onBack,
                      // The asset points right (RTL "back"), mirrored in LTR.
                      child: Transform.flip(
                        flipX: !rtl,
                        child: SvgPicture.asset(
                          'assets/icons/arrow_back.svg',
                          width: 24.r,
                          height: 24.r,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _FavoriteAction(product: product),
                    SizedBox(width: 8.w),
                    RoundIconButton(
                      key: const ValueKey('product-share'),
                      label: shareLabel,
                      onTap: onShare,
                      child: SvgPicture.asset(
                        'assets/icons/account/share.svg',
                        width: 24.r,
                        height: 24.r,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    RoundIconButton(
                      key: const ValueKey('product-cart'),
                      label: cartLabel,
                      onTap: onCart,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/home/cart_bag.svg',
                            width: 24.r,
                            height: 24.r,
                          ),
                          PositionedDirectional(
                            top: -8.r,
                            end: -6.r,
                            child: CountBadge(count: cartCount),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (product.viewersNow > 0)
            PositionedDirectional(
              end: 0,
              bottom: 16.h,
              child: ViewersChip(count: product.viewersNow),
            ),
        ],
      ),
    );
  }
}

class _FavoriteAction extends StatelessWidget {
  const _FavoriteAction({required this.product});

  final ProductDetails product;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavoritesCubit, Set<int>, bool>(
      selector: (ids) => ids.contains(product.id),
      builder: (context, favorite) => RoundIconButton(
        key: const ValueKey('product-favorite'),
        label: (favorite ? 'home.remove_favorite' : 'home.add_favorite').tr(
          context: context,
        ),
        onTap: () => context.read<FavoritesCubit>().toggleId(product.id),
        child: favorite
            ? Icon(Icons.favorite, size: 24.r, color: AppColors.error)
            : SvgPicture.asset(
                'assets/icons/home/heart.svg',
                width: 24.r,
                height: 24.r,
              ),
      ),
    );
  }
}

/// Category link, name, prices and the description.
class _Info extends StatelessWidget {
  const _Info({
    required this.product,
    required this.onOpenCategory,
    required this.detailsTitle,
  });

  final ProductDetails product;
  final VoidCallback onOpenCategory;
  final String detailsTitle;

  @override
  Widget build(BuildContext context) {
    final currency = 'home.currency'.tr(context: context);
    String money(double v) => '${v.toStringAsFixed(2)} $currency';
    final old = product.oldPrice;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: const ValueKey('product-category'),
            onTap: onOpenCategory,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.categoryName,
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),
                SizedBox(width: 4.w),
                // Material mirrors this icon in RTL, so it points to the end
                // edge in both languages (left in Arabic).
                Icon(
                  Icons.chevron_right,
                  size: 20.r,
                  color: AppColors.textDefault,
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            product.name,
            style: AppTextStyles.textLgBold.copyWith(
              color: AppColors.textDefault,
              fontSize: 20.sp,
              height: 28 / 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                money(product.finalPrice),
                style: AppTextStyles.displayXsBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (old != null)
                Text(
                  money(old),
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Divider(height: 1, color: AppColors.neutral200),
          ),
          Text(
            detailsTitle,
            style: AppTextStyles.textLgBold.copyWith(
              color: AppColors.textDefault,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            product.description,
            style: AppTextStyles.textMdRegular.copyWith(
              color: AppColors.textLabel,
            ),
          ),
        ],
      ),
    );
  }
}
