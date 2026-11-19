import '../../../../core/utils/result.dart';
import '../../domain/entities/legal_document.dart';
import '../../domain/repositories/legal_repository.dart';
import '../datasources/legal_data_source.dart';

class LegalRepositoryImpl implements LegalRepository {
  const LegalRepositoryImpl(this._source);

  final LegalDataSource _source;

  @override
  Future<Result<LegalDocument>> getDocument(
    LegalDocumentType type,
    String languageCode,
  ) => guard(() => _source.fetch(type, languageCode));
}
