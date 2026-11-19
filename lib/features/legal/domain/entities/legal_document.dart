import 'package:equatable/equatable.dart';

enum LegalDocumentType { terms, privacy }

class LegalSection extends Equatable {
  const LegalSection({required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  List<Object?> get props => [heading, body];
}

/// A legal text: a title and numbered sections.
class LegalDocument extends Equatable {
  const LegalDocument({
    required this.type,
    required this.title,
    required this.intro,
    required this.sections,
  });

  final LegalDocumentType type;
  final String title;
  final String intro;
  final List<LegalSection> sections;

  @override
  List<Object?> get props => [type, title, intro, sections];
}
