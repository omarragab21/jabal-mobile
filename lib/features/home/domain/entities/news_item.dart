import 'package:equatable/equatable.dart';

/// One line of the news ticker.
class NewsItem extends Equatable {
  const NewsItem({required this.id, required this.text});

  final String id;
  final String text;

  @override
  List<Object?> get props => [id, text];
}
