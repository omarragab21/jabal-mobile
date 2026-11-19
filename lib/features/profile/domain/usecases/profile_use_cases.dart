import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  const GetProfile(this._repository);
  final ProfileRepository _repository;

  Future<Result<UserProfile>> call() => _repository.getProfile();
}

class UpdateName {
  const UpdateName(this._repository);
  final ProfileRepository _repository;

  Future<Result<UserProfile>> call(String name) => _repository.updateName(name);
}

class UpdateEmail {
  const UpdateEmail(this._repository);
  final ProfileRepository _repository;

  Future<Result<UserProfile>> call(String email) =>
      _repository.updateEmail(email);
}

class UpdateGender {
  const UpdateGender(this._repository);
  final ProfileRepository _repository;

  Future<Result<UserProfile>> call(Gender? gender) =>
      _repository.updateGender(gender);
}

class UpdateBirthDate {
  const UpdateBirthDate(this._repository);
  final ProfileRepository _repository;

  Future<Result<UserProfile>> call(DateTime? date) =>
      _repository.updateBirthDate(date);
}

class RequestPhoneChange {
  const RequestPhoneChange(this._repository);
  final ProfileRepository _repository;

  Future<Result<void>> call(String e164) =>
      _repository.requestPhoneChange(e164);
}

class ConfirmPhoneChange {
  const ConfirmPhoneChange(this._repository);
  final ProfileRepository _repository;

  Future<Result<UserProfile>> call(String e164, String code) =>
      _repository.confirmPhoneChange(e164, code);
}
