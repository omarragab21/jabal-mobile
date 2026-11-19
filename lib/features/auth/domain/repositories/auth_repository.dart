import '../../../../core/utils/result.dart';
import '../entities/auth_session.dart';
import '../entities/phone_number.dart';
import '../entities/registration_data.dart';

/// What the auth feature needs from the outside world. The implementation can
/// talk to a mock or a real API without the domain/UI knowing.
abstract interface class AuthRepository {
  /// Checks the credentials and sends a verification code to [phone].
  Future<Result<void>> login({
    required PhoneNumber phone,
    required String password,
  });

  /// Creates the account and sends a verification code to its phone.
  Future<Result<void>> register(RegistrationData data);

  /// Confirms the code; on success the session is saved on the device.
  Future<Result<AuthSession>> verifyOtp({
    required PhoneNumber phone,
    required String code,
  });

  Future<Result<void>> resendOtp(PhoneNumber phone);

  /// The saved session, or `null` when the user isn't signed in.
  Future<Result<AuthSession?>> currentSession();

  Future<Result<void>> logout();
}
