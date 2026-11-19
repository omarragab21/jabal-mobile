import '../../../../core/utils/result.dart';
import '../entities/legal_document.dart';
import '../repositories/legal_repository.dart';

class GetLegalDocument {
  const GetLegalDocument(this._repository);
  final LegalRepository _repository;

  Future<Result<LegalDocument>> call(
    LegalDocumentType type,
    String languageCode,
  ) => _repository.getDocument(type, languageCode);
}
