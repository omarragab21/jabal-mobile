import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../cubit/favorites_cubit.dart';
import 'product_card.dart';

/// Opens a product's page; gets the context of the tapped page to navigate
/// with.
typedef ProductOpener = void Function(BuildContext context, Product product);

/// A [ProductCard] wired to the shared favourites and the app language:
/// currency and button texts come from the translations, the heart from
/// [FavoritesCubit].
class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  final Product product;

  /// The card was tapped (open the product's page).
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final favorites = context.read<FavoritesCubit>();
    return BlocSelector<FavoritesCubit, Set<int>, bool>(
      selector: (ids) => ids.contains(product.id),
      builder: (context, favorite) => ProductCard(
        product: product,
        currency: 'home.currency'.tr(context: context),
        addToCartLabel: 'home.add_to_cart'.tr(context: context),
        favoriteLabel: (favorite ? 'home.remove_favorite' : 'home.add_favorite')
            .tr(context: context),
        isFavorite: favorite,
        onTap: onTap,
        onFavorite: () => favorites.toggle(product),
        onAddToCart: onAddToCart,
      ),
    );
  }
}

/// Shows the "added to your cart" message for [product].
void showAddedToCart(BuildContext context, Product product) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'home.added_to_cart'.tr(context: context, args: [product.name]),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}
