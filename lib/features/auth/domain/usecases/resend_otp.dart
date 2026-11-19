import '../../../../core/utils/result.dart';
import '../entities/phone_number.dart';
import '../repositories/auth_repository.dart';

class ResendOtp {
  const ResendOtp(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call(PhoneNumber phone) => _repository.resendOtp(phone);
}
