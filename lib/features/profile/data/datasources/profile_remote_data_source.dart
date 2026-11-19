import '../../../../core/error/exceptions.dart';

/// The backend side of changing the account phone number.
abstract interface class ProfileRemoteDataSource {
  /// Sends a code to [e164]. Throws an `AppException` on failure.
  Future<void> requestPhoneChange(String e164);

  /// Throws `ServerException(invalidOtp)` when [code] is wrong.
  Future<void> confirmPhoneChange(String e164, String code);
}

/// Error code of a wrong verification code.
const String profileInvalidOtp = 'invalid_otp';

/// Offline fake backend: the right code is [validOtp].
class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  const MockProfileRemoteDataSource({
    this.latency = const Duration(milliseconds: 600),
  });

  static const String validOtp = '5991';

  final Duration latency;

  Future<void> _wait() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }

  @override
  Future<void> requestPhoneChange(String e164) => _wait();

  @override
  Future<void> confirmPhoneChange(String e164, String code) async {
    await _wait();
    if (code != validOtp) {
      throw const ServerException(profileInvalidOtp, statusCode: 400);
    }
  }
}
