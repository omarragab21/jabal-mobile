import 'package:equatable/equatable.dart';

/// One result of searching for a street or an area.
class PlaceSuggestion extends Equatable {
  const PlaceSuggestion({required this.placeId, required this.description});

  final String placeId;
  final String description;

  @override
  List<Object?> get props => [placeId, description];
}
