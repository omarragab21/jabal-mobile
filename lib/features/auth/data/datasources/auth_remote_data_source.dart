import '../models/auth_session_model.dart';

/// Server error codes carried in `ServerException.message`. Both the mock and
/// the API data source use them so the repository maps errors in one place.
abstract final class AuthErrorCodes {
  static const String invalidCredentials = 'invalid_credentials';
  static const String userNotFound = 'user_not_found';
  static const String phoneTaken = 'phone_taken';
  static const String invalidOtp = 'invalid_otp';
  static const String accountBlocked = 'account_blocked';
}

/// Remote side of auth. Swap [MockAuthRemoteDataSource] for
/// [ApiAuthRemoteDataSource] in `AuthModule` — nothing else changes.
abstract interface class AuthRemoteDataSource {
  Future<void> login({required String phone, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String code,
  });

  Future<void> resendOtp(String phone);
}
