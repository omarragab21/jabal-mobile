import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/phone_number.dart';
import '../../domain/entities/registration_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Result<void>> login({
    required PhoneNumber phone,
    required String password,
  }) => _run(() => _remote.login(phone: phone.e164, password: password));

  @override
  Future<Result<void>> register(RegistrationData data) => _run(
    () => _remote.register(
      name: data.name.trim(),
      email: data.email.trim(),
      phone: data.phone.e164,
      password: data.password,
    ),
  );

  @override
  Future<Result<AuthSession>> verifyOtp({
    required PhoneNumber phone,
    required String code,
  }) => _run<AuthSession>(() async {
    final session = await _remote.verifyOtp(phone: phone.e164, code: code);
    await _local.saveSession(session);
    return session;
  });

  @override
  Future<Result<void>> resendOtp(PhoneNumber phone) =>
      _run(() => _remote.resendOtp(phone.e164));

  @override
  Future<Result<AuthSession?>> currentSession() =>
      _run<AuthSession?>(() async => _local.readSession());

  @override
  Future<Result<void>> logout() => _run(_local.clearSession);

  /// Runs [call] and turns known server error codes into domain failures.
  Future<Result<T>> _run<T>(Future<T> Function() call) async {
    final result = await guard(call);
    return switch (result) {
      Err<T>(failure: final f) => Err(_map(f)),
      _ => result,
    };
  }

  Failure _map(Failure f) {
    if (f is! ServerFailure) return f;
    return switch (f.message) {
      AuthErrorCodes.invalidCredentials => const InvalidCredentialsFailure(),
      AuthErrorCodes.userNotFound => const UserNotFoundFailure(),
      AuthErrorCodes.phoneTaken => const PhoneAlreadyRegisteredFailure(),
      AuthErrorCodes.invalidOtp => const InvalidOtpFailure(),
      AuthErrorCodes.accountBlocked => const AccountBlockedFailure(),
      _ => f,
    };
  }
}
