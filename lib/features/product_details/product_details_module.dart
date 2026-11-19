import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/platform/clipboard_writer.dart';
import '../../core/platform/link_opener.dart';
import '../../core/sharing/share_link.dart';
import '../cart/domain/usecases/add_to_cart.dart';
import '../cart/domain/usecases/update_cart_item.dart';
import '../cart/domain/usecases/watch_cart_count.dart';
import '../home/presentation/cubit/favorites_cubit.dart';
import 'data/datasources/mock_product_details_remote_data_source.dart';
import 'data/datasources/product_details_remote_data_source.dart';
import 'data/repositories/product_details_repository_impl.dart';
import 'domain/repositories/product_details_repository.dart';
import 'domain/usecases/get_product_details.dart';
import 'presentation/cubit/product_details_cubit.dart';
import 'presentation/pages/product_details_page.dart';
import 'presentation/product_details_args.dart';

/// The product page. It runs on mock data until a real
/// [ProductDetailsRemoteDataSource] is passed as [remote]; the cart use cases
/// and the favourites are the app's shared ones.
class ProductDetailsModule {
  ProductDetailsModule({
    required AddToCart addToCart,
    required UpdateCartItem updateCartItem,
    required WatchCartCount watchCartCount,
    required FavoritesCubit favorites,
    ProductDetailsRemoteDataSource? remote,
    LinkOpener? linkOpener,
    ClipboardWriter? clipboard,
    Duration latency = const Duration(milliseconds: 500),
  }) : _addToCart = addToCart,
       _updateCartItem = updateCartItem,
       _watchCartCount = watchCartCount,
       _favorites = favorites,
       _repository = ProductDetailsRepositoryImpl(
         remote ?? MockProductDetailsRemoteDataSource(latency: latency),
       ),
       _shareLink = ShareLink(
         linkOpener ?? const UrlLauncherLinkOpener(),
         clipboard ?? const SystemClipboardWriter(),
       );

  final AddToCart _addToCart;
  final UpdateCartItem _updateCartItem;
  final WatchCartCount _watchCartCount;
  final FavoritesCubit _favorites;
  final ProductDetailsRepository _repository;
  final ShareLink _shareLink;

  /// The page of the product in [args]. [onOpenCart] jumps to the cart tab;
  /// [onOpenCategory] opens the category the product belongs to.
  Widget page(
    ProductDetailsArgs args, {
    required ValueChanged<BuildContext> onOpenCart,
    required void Function(BuildContext context, int categoryId) onOpenCategory,
  }) => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: _favorites),
      BlocProvider(
        create: (_) => ProductDetailsCubit(
          args: args,
          getProductDetails: GetProductDetails(_repository),
          addToCart: _addToCart,
          updateCartItem: _updateCartItem,
          watchCartCount: _watchCartCount,
          shareLink: _shareLink,
        ),
      ),
    ],
    child: ProductDetailsPage(
      onOpenCart: onOpenCart,
      onOpenCategory: onOpenCategory,
    ),
  );
}
