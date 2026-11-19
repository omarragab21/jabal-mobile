import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._local, this._remote);

  final ProfileLocalDataSource _local;
  final ProfileRemoteDataSource _remote;

  UserProfile _current() => _local.read() ?? (throw const NotFoundException());

  /// Applies [change] to the saved profile and saves the result.
  Future<Result<UserProfile>> _update(
    UserProfile Function(UserProfile current) change,
  ) => guard(() async {
    final updated = change(_current());
    await _local.write(updated);
    return updated;
  });

  @override
  Future<Result<UserProfile>> getProfile() => guard(() async => _current());

  @override
  Future<Result<UserProfile>> updateName(String name) =>
      _update((p) => p.copyWith(name: name));

  @override
  Future<Result<UserProfile>> updateEmail(String email) =>
      _update((p) => p.copyWith(email: () => email));

  @override
  Future<Result<UserProfile>> updateGender(Gender? gender) =>
      _update((p) => p.copyWith(gender: () => gender));

  @override
  Future<Result<UserProfile>> updateBirthDate(DateTime? date) =>
      _update((p) => p.copyWith(birthDate: () => date));

  @override
  Future<Result<void>> requestPhoneChange(String e164) =>
      guard(() => _remote.requestPhoneChange(e164));

  @override
  Future<Result<UserProfile>> confirmPhoneChange(
    String e164,
    String code,
  ) async {
    try {
      await _remote.confirmPhoneChange(e164, code);
    } on ServerException catch (e) {
      if (e.message == profileInvalidOtp) {
        return const Err(InvalidOtpFailure());
      }
      return Err(Failure.fromException(e));
    } on AppException catch (e) {
      return Err(Failure.fromException(e));
    }
    return _update((p) => p.copyWith(phone: e164));
  }
}
