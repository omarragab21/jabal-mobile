import '../../../../core/utils/result.dart';
import '../entities/phone_number.dart';
import '../repositories/auth_repository.dart';

class Login {
  const Login(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call({
    required PhoneNumber phone,
    required String password,
  }) => _repository.login(phone: phone, password: password);
}
