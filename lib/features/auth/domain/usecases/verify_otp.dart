import '../../../../core/utils/result.dart';
import '../entities/auth_session.dart';
import '../entities/phone_number.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp {
  const VerifyOtp(this._repository);
  final AuthRepository _repository;

  Future<Result<AuthSession>> call({
    required PhoneNumber phone,
    required String code,
  }) => _repository.verifyOtp(phone: phone, code: code);
}
