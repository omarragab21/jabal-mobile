import '../../../../core/error/exceptions.dart';
import '../models/auth_session_model.dart';
import 'auth_remote_data_source.dart';

/// Offline fake backend for trying the UI. Behaviour:
/// * Demo account: phone `+962791234567`, password `123456`.
/// * Accounts created through sign-up work for login (kept in memory).
/// * Blocked demo account: phone `+962780000000` (any password) shows the
///   "account can't be used" dialog.
/// * The correct verification code is [validOtp]; anything else is rejected.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  MockAuthRemoteDataSource({this.latency = const Duration(milliseconds: 900)}) {
    _users['+962791234567'] = const _MockUser(
      id: '1',
      name: 'أحمد محمد',
      email: 'ahmad@example.com',
      password: '123456',
    );
  }

  static const String validOtp = '5991';

  /// Numbers that exist but may not sign in (E.164).
  static const Set<String> blockedPhones = {'+962780000000'};

  final Duration latency;
  final Map<String, _MockUser> _users = {};
  int _nextId = 2;

  Future<void> _wait() => Future<void>.delayed(latency);

  @override
  Future<void> login({required String phone, required String password}) async {
    await _wait();
    if (blockedPhones.contains(phone)) {
      throw const ServerException(
        AuthErrorCodes.accountBlocked,
        statusCode: 403,
      );
    }
    final user = _users[phone];
    if (user == null) {
      throw const ServerException(AuthErrorCodes.userNotFound, statusCode: 404);
    }
    if (user.password != password) {
      throw const ServerException(
        AuthErrorCodes.invalidCredentials,
        statusCode: 400,
      );
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _wait();
    if (_users.containsKey(phone)) {
      throw const ServerException(AuthErrorCodes.phoneTaken, statusCode: 409);
    }
    _users[phone] = _MockUser(
      id: '${_nextId++}',
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String code,
  }) async {
    await _wait();
    final user = _users[phone];
    if (code != validOtp || user == null) {
      throw const ServerException(AuthErrorCodes.invalidOtp, statusCode: 422);
    }
    return AuthSessionModel(
      token: 'mock-token-${user.id}',
      user: AuthUserModel(
        id: user.id,
        name: user.name,
        phone: phone,
        email: user.email,
      ),
    );
  }

  @override
  Future<void> resendOtp(String phone) => _wait();
}

class _MockUser {
  const _MockUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  final String id;
  final String name;
  final String email;
  final String password;
}
