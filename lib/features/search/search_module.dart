import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cart/domain/usecases/add_to_cart.dart';
import '../home/domain/usecases/contact_support.dart';
import '../home/domain/usecases/search_products.dart';
import '../home/presentation/cubit/favorites_cubit.dart';
import '../home/presentation/widgets/product_tile.dart';
import 'data/datasources/mock_search_remote_data_source.dart';
import 'data/datasources/search_remote_data_source.dart';
import 'data/repositories/search_repository_impl.dart';
import 'domain/repositories/search_repository.dart';
import 'domain/usecases/get_search_suggestions.dart';
import 'presentation/cubit/search_cubit.dart';
import 'presentation/pages/search_page.dart';

/// The product search screen, opened from the search fields of the shop. The
/// products come from the shop's own search; the suggestions run on mock data
/// until a real [SearchRemoteDataSource] is passed as [remote].
class SearchModule {
  SearchModule({
    required SearchProducts searchProducts,
    required AddToCart addToCart,
    required ContactSupport contactSupport,
    required FavoritesCubit favorites,
    SearchRemoteDataSource? remote,
    Duration latency = const Duration(milliseconds: 150),
    this.suggestionDebounce = const Duration(milliseconds: 250),
  }) : _searchProducts = searchProducts,
       _addToCart = addToCart,
       _contactSupport = contactSupport,
       _favorites = favorites,
       _repository = SearchRepositoryImpl(
         remote ?? MockSearchRemoteDataSource(latency: latency),
       );

  final SearchProducts _searchProducts;
  final AddToCart _addToCart;
  final ContactSupport _contactSupport;
  final FavoritesCubit _favorites;
  final SearchRepository _repository;
  final Duration suggestionDebounce;

  /// Opens the search screen over the current page. [onOpenProduct] opens a
  /// product the customer tapped in the results.
  Future<void> open(BuildContext context, {ProductOpener? onOpenProduct}) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _favorites),
              BlocProvider(
                create: (_) => SearchCubit(
                  getSuggestions: GetSearchSuggestions(_repository),
                  searchProducts: _searchProducts,
                  addToCart: _addToCart,
                  contactSupport: _contactSupport,
                  suggestionDebounce: suggestionDebounce,
                ),
              ),
            ],
            child: SearchPage(onOpenProduct: onOpenProduct),
          ),
        ),
      );
}
