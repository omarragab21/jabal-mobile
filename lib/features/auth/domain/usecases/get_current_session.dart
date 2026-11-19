import '../../../../core/utils/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class GetCurrentSession {
  const GetCurrentSession(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthSession?>> call() => _repository.currentSession();
}
