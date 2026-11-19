import 'package:equatable/equatable.dart';

/// A slide of the home carousel.
class HomeBanner extends Equatable {
  const HomeBanner({
    required this.id,
    required this.imageUrl,
    this.title = '',
    this.description = '',
    this.link,
    this.order = 0,
  });

  final int id;
  final String imageUrl;
  final String title;
  final String description;

  /// Where a tap should go; null = not tappable.
  final String? link;
  final int order;

  @override
  List<Object?> get props => [id, imageUrl, title, description, link, order];
}
