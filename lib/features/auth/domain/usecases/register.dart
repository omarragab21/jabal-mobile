import '../../../../core/utils/result.dart';
import '../entities/registration_data.dart';
import '../repositories/auth_repository.dart';

class Register {
  const Register(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call(RegistrationData data) =>
      _repository.register(data);
}
