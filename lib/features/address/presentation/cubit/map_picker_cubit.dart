import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/geo_point.dart';
import '../../domain/entities/place_suggestion.dart';
import '../../domain/usecases/place_use_cases.dart';
import 'map_picker_state.dart';

/// View model of the map page: the pin follows the map centre, and each time
/// the map stops the centre is turned into an address and checked against
/// the delivery area. Also runs the place search.
class MapPickerCubit extends Cubit<MapPickerState> {
  MapPickerCubit({
    required GeoPoint start,
    required SearchPlaces searchPlaces,
    required GetPlacePoint getPlacePoint,
    required DescribePlace describePlace,
    required CheckDeliveryArea checkDeliveryArea,
    this.searchDebounce = const Duration(milliseconds: 350),
  }) : _searchPlaces = searchPlaces,
       _getPlacePoint = getPlacePoint,
       _describePlace = describePlace,
       _checkDeliveryArea = checkDeliveryArea,
       super(MapPickerState(point: start));

  final SearchPlaces _searchPlaces;
  final GetPlacePoint _getPlacePoint;
  final DescribePlace _describePlace;
  final CheckDeliveryArea _checkDeliveryArea;
  final Duration searchDebounce;

  final StreamController<GeoPoint> _moves = StreamController.broadcast();
  Timer? _debounce;
  String _languageCode = 'ar';
  int _placeToken = 0;
  int _searchToken = 0;

  /// Points the map should fly to (a search result, the device position).
  Stream<GeoPoint> get moveRequests => _moves.stream;

  /// Looks up the start point. [languageCode] is the app language.
  Future<void> start(String languageCode) {
    _languageCode = languageCode;
    return _resolve(state.point);
  }

  /// The language changed: describe the current point again.
  Future<void> changeLanguage(String languageCode) {
    if (languageCode == _languageCode) return Future.value();
    _languageCode = languageCode;
    return _resolve(state.point);
  }

  /// The map is moving: the old address no longer matches the pin.
  void onCameraMove(GeoPoint point) {
    if (point == state.point) return;
    emit(
      state.copyWith(
        point: point,
        placeStatus: PlaceStatus.loading,
        place: () => null,
        deliverable: () => null,
      ),
    );
  }

  /// The map stopped at [point].
  Future<void> onCameraIdle(GeoPoint point) {
    if (point != state.point || state.placeStatus != PlaceStatus.loading) {
      emit(
        state.copyWith(
          point: point,
          placeStatus: PlaceStatus.loading,
          place: () => null,
          deliverable: () => null,
        ),
      );
    }
    return _resolve(point);
  }

  Future<void> _resolve(GeoPoint point) async {
    final token = ++_placeToken;
    final results = await (
      _describePlace(point, _languageCode),
      _checkDeliveryArea(point),
    ).wait;
    if (isClosed || token != _placeToken) return;
    final place = results.$1.when(success: (p) => p, failure: (_) => null);
    emit(
      state.copyWith(
        point: point,
        placeStatus: place == null ? PlaceStatus.failed : PlaceStatus.ready,
        place: () => place,
        deliverable: () => results.$2,
      ),
    );
  }

  /// Called on every change of the search field.
  void onQueryChanged(String text) {
    final query = text.trim();
    if (query == state.query) return;
    _debounce?.cancel();
    _searchToken++;
    if (query.length < SearchPlaces.minLength) {
      emit(
        state.copyWith(
          query: query,
          suggestionsStatus: SuggestionsStatus.idle,
          suggestions: const [],
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        query: query,
        suggestionsStatus: SuggestionsStatus.searching,
      ),
    );
    _debounce = Timer(searchDebounce, () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    final token = ++_searchToken;
    final result = await _searchPlaces(query, _languageCode);
    if (isClosed || token != _searchToken) return;
    result.when(
      success: (list) => emit(
        state.copyWith(
          suggestionsStatus: SuggestionsStatus.done,
          suggestions: list,
        ),
      ),
      failure: (_) => emit(
        state.copyWith(
          suggestionsStatus: SuggestionsStatus.failed,
          suggestions: const [],
        ),
      ),
    );
  }

  /// Hides the suggestions without clearing the field.
  void closeSuggestions() {
    _debounce?.cancel();
    _searchToken++;
    if (state.showSuggestions) {
      emit(
        state.copyWith(
          suggestionsStatus: SuggestionsStatus.idle,
          suggestions: const [],
        ),
      );
    }
  }

  /// Flies the map to a search result.
  Future<void> selectSuggestion(PlaceSuggestion suggestion) async {
    closeSuggestions();
    final result = await _getPlacePoint(suggestion);
    if (isClosed) return;
    result.when(
      success: _moves.add,
      failure: (_) =>
          emit(state.copyWith(suggestionsStatus: SuggestionsStatus.failed)),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _moves.close();
    return super.close();
  }
}
