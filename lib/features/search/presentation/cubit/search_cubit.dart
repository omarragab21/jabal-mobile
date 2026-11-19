import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/domain/usecases/add_to_cart.dart';
import '../../../home/domain/entities/product.dart';
import '../../../home/domain/usecases/contact_support.dart';
import '../../../home/domain/usecases/search_products.dart';
import '../../domain/usecases/get_search_suggestions.dart';

/// What the search screen shows.
enum SearchPhase {
  /// Nothing typed yet: an empty screen.
  idle,

  /// Typing: the list of texts to complete to.
  suggesting,

  /// A search is running.
  searching,

  /// The products found (or none, which is its own view).
  results,
  failed,
}

class SearchState extends Equatable {
  const SearchState({
    this.phase = SearchPhase.idle,
    this.query = '',
    this.suggestions = const [],
    this.results = const [],
  });

  /// The text being searched or typed (trimmed).
  final String query;
  final SearchPhase phase;
  final List<String> suggestions;
  final List<Product> results;

  bool get hasNoResults => phase == SearchPhase.results && results.isEmpty;

  SearchState copyWith({
    SearchPhase? phase,
    String? query,
    List<String>? suggestions,
    List<Product>? results,
  }) => SearchState(
    phase: phase ?? this.phase,
    query: query ?? this.query,
    suggestions: suggestions ?? this.suggestions,
    results: results ?? this.results,
  );

  @override
  List<Object?> get props => [phase, query, suggestions, results];
}

/// View model of the search screen. Typing asks for suggestions (after a short
/// pause, only the latest answer counts); picking a suggestion or submitting
/// the keyboard runs the product search.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required GetSearchSuggestions getSuggestions,
    required SearchProducts searchProducts,
    required AddToCart addToCart,
    required ContactSupport contactSupport,
    this.suggestionDebounce = const Duration(milliseconds: 250),
  }) : _getSuggestions = getSuggestions,
       _searchProducts = searchProducts,
       _addToCart = addToCart,
       _contactSupport = contactSupport,
       super(const SearchState());

  final GetSearchSuggestions _getSuggestions;
  final SearchProducts _searchProducts;
  final AddToCart _addToCart;
  final ContactSupport _contactSupport;

  /// How long typing must pause before suggestions are asked for.
  final Duration suggestionDebounce;

  Timer? _debounce;
  String _languageCode = 'ar';

  /// Every typing or search bumps this; an older answer arriving later finds
  /// a different number and is dropped.
  int _token = 0;

  /// The language the texts are asked for in.
  void setLanguage(String languageCode) => _languageCode = languageCode;

  /// Called on every change of the field.
  void queryChanged(String text) {
    final query = text.trim();
    _debounce?.cancel();
    final token = ++_token;
    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }
    // Keep the old suggestions on screen while the new ones load, so the list
    // does not blink on every key.
    emit(
      state.copyWith(
        phase: SearchPhase.suggesting,
        query: query,
        results: const [],
        suggestions: state.phase == SearchPhase.suggesting
            ? state.suggestions
            : const [],
      ),
    );
    if (suggestionDebounce == Duration.zero) {
      _loadSuggestions(query, token);
    } else {
      _debounce = Timer(
        suggestionDebounce,
        () => _loadSuggestions(query, token),
      );
    }
  }

  Future<void> _loadSuggestions(String query, int token) async {
    final result = await _getSuggestions(query, _languageCode);
    if (isClosed || token != _token) return;
    result.when(
      // Suggestions are a help: when they fail the field still works.
      success: (list) => emit(state.copyWith(suggestions: list)),
      failure: (_) => emit(state.copyWith(suggestions: const [])),
    );
  }

  /// Searches the products for [text].
  Future<void> submit(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;
    _debounce?.cancel();
    final token = ++_token;
    emit(
      state.copyWith(
        phase: SearchPhase.searching,
        query: query,
        suggestions: const [],
        results: const [],
      ),
    );
    final result = await _searchProducts(query, _languageCode);
    if (isClosed || token != _token) return;
    result.when(
      success: (products) =>
          emit(state.copyWith(phase: SearchPhase.results, results: products)),
      failure: (_) => emit(state.copyWith(phase: SearchPhase.failed)),
    );
  }

  Future<void> retry() => submit(state.query);

  Future<void> addToCart(Product product) => _addToCart(product.id);

  /// Opens a chat with the pharmacist; true when it opened.
  Future<bool> askPharmacist(String message) async => (await _contactSupport(
    message,
  )).when(success: (_) => true, failure: (_) => false);

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
