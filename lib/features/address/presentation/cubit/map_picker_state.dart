import 'package:equatable/equatable.dart';

import '../../domain/entities/delivery_location.dart';
import '../../domain/entities/geo_point.dart';
import '../../domain/entities/place_info.dart';
import '../../domain/entities/place_suggestion.dart';

enum PlaceStatus { loading, ready, failed }

enum SuggestionsStatus { idle, searching, done, failed }

class MapPickerState extends Equatable {
  const MapPickerState({
    required this.point,
    this.placeStatus = PlaceStatus.loading,
    this.place,
    this.deliverable,
    this.query = '',
    this.suggestionsStatus = SuggestionsStatus.idle,
    this.suggestions = const [],
  });

  /// The point under the pin (the map centre).
  final GeoPoint point;
  final PlaceStatus placeStatus;

  /// The text of [point]; null while loading or when unknown.
  final PlaceInfo? place;

  /// Null until the check for [point] is done.
  final bool? deliverable;

  /// Text in the search field (trimmed).
  final String query;
  final SuggestionsStatus suggestionsStatus;
  final List<PlaceSuggestion> suggestions;

  bool get showSuggestions => suggestionsStatus != SuggestionsStatus.idle;

  /// Shows the "delivery is not available here" message.
  bool get outsideDeliveryArea =>
      placeStatus == PlaceStatus.ready && deliverable == false;

  /// The place can be confirmed: it has a text and the store delivers there.
  bool get canConfirm =>
      placeStatus == PlaceStatus.ready && place != null && deliverable == true;

  /// What confirming picks; null when [canConfirm] is false.
  DeliveryLocation? get location => canConfirm
      ? DeliveryLocation(
          point: point,
          label: place!.headline,
          details: place!.details,
        )
      : null;

  MapPickerState copyWith({
    GeoPoint? point,
    PlaceStatus? placeStatus,
    PlaceInfo? Function()? place,
    bool? Function()? deliverable,
    String? query,
    SuggestionsStatus? suggestionsStatus,
    List<PlaceSuggestion>? suggestions,
  }) => MapPickerState(
    point: point ?? this.point,
    placeStatus: placeStatus ?? this.placeStatus,
    place: place != null ? place() : this.place,
    deliverable: deliverable != null ? deliverable() : this.deliverable,
    query: query ?? this.query,
    suggestionsStatus: suggestionsStatus ?? this.suggestionsStatus,
    suggestions: suggestions ?? this.suggestions,
  );

  @override
  List<Object?> get props => [
    point,
    placeStatus,
    place,
    deliverable,
    query,
    suggestionsStatus,
    suggestions,
  ];
}
