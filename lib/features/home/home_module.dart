import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/platform/link_opener.dart';
import '../cart/domain/usecases/add_to_cart.dart';
import '../cart/domain/usecases/watch_cart_count.dart';
import 'data/datasources/home_remote_data_source.dart';
import 'data/datasources/mock_home_remote_data_source.dart';
import 'data/repositories/home_repository_impl.dart';
import 'domain/entities/product_category.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/usecases/contact_support.dart';
import 'domain/usecases/get_category_page.dart';
import 'domain/usecases/get_home_data.dart';
import 'domain/usecases/search_products.dart';
import 'presentation/cubit/category_cubit.dart';
import 'presentation/cubit/favorites_cubit.dart';
import 'presentation/cubit/home_cubit.dart';
import 'presentation/pages/category_args.dart';
import 'presentation/pages/category_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/widgets/product_tile.dart';

/// Wires the home feature and its category pages. It runs on mock data until
/// a real [HomeRemoteDataSource] (`ApiHomeRemoteDataSource`) is passed as
/// [remote].
class HomeModule {
  HomeModule({
    required AddToCart addToCart,
    required WatchCartCount watchCartCount,
    HomeRemoteDataSource? remote,
    LinkOpener? linkOpener,
    this.animations = true,
  }) : _linkOpener = linkOpener ?? const UrlLauncherLinkOpener(),
       _addToCart = addToCart,
       _watchCartCount = watchCartCount,
       _repository = HomeRepositoryImpl(
         remote ?? const MockHomeRemoteDataSource(),
       );

  final LinkOpener _linkOpener;
  final AddToCart _addToCart;
  final WatchCartCount _watchCartCount;
  final HomeRepository _repository;

  /// One favourites list for the home page and every category page.
  final FavoritesCubit _favorites = FavoritesCubit();

  /// The catalogue, for the features that show the same products.
  HomeRepository get repository => _repository;

  /// The shared favourites.
  FavoritesCubit get favorites => _favorites;

  /// False stops the news bar and banner auto-play (tests).
  final bool animations;

  /// The shop's product search, for the search screen.
  SearchProducts get searchProducts => SearchProducts(_repository);

  /// "Ask the pharmacist": a WhatsApp chat with the support team.
  ContactSupport get contactSupport => ContactSupport(_repository, _linkOpener);

  Widget page({
    VoidCallback? onOpenCategories,
    ValueChanged<ProductCategory>? onOpenCategory,
    ProductOpener? onOpenProduct,
    VoidCallback? onOpenSearch,
    Widget Function(Widget below)? deliveryHeaderBuilder,
  }) => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: _favorites),
      BlocProvider(
        create: (_) => HomeCubit(
          getHomeData: GetHomeData(_repository),
          addToCart: _addToCart,
          contactSupport: contactSupport,
        ),
      ),
    ],
    child: HomePage(
      animations: animations,
      onOpenCategories: onOpenCategories,
      onOpenCategory: onOpenCategory,
      onOpenProduct: onOpenProduct,
      onOpenSearch: onOpenSearch,
      deliveryHeaderBuilder: deliveryHeaderBuilder,
    ),
  );

  /// The page of a section; its chips filter the products in place.
  /// [onOpenCart] jumps to the cart tab.
  Widget categoryPage(
    CategoryArgs args, {
    required ValueChanged<BuildContext> onOpenCart,
    ProductOpener? onOpenProduct,
  }) => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: _favorites),
      BlocProvider(
        create: (_) => CategoryCubit(
          categoryId: args.categoryId,
          getCategoryPage: GetCategoryPage(_repository),
          addToCart: _addToCart,
          watchCartCount: _watchCartCount,
        ),
      ),
    ],
    child: CategoryPage(onOpenCart: onOpenCart, onOpenProduct: onOpenProduct),
  );
}
