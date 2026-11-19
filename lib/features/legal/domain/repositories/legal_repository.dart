import '../../../../core/utils/result.dart';
import '../entities/legal_document.dart';

abstract interface class LegalRepository {
  /// The text of [type] in [languageCode] (`ar` / `en`).
  Future<Result<LegalDocument>> getDocument(
    LegalDocumentType type,
    String languageCode,
  );
}
