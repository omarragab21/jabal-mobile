import '../../../../core/network/api_client.dart';
import '../models/auth_session_model.dart';
import 'auth_remote_data_source.dart';

/// Real backend implementation on top of [ApiClient].
/// The endpoint paths and payload keys below are placeholders until the API
/// contract is defined — adjust them here only.
class ApiAuthRemoteDataSource implements AuthRemoteDataSource {
  const ApiAuthRemoteDataSource(this._client);

  final ApiClient _client;

  @override
  Future<void> login({required String phone, required String password}) =>
      _client.post('/auth/login', data: {'phone': phone, 'password': password});

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) => _client.post(
    '/auth/register',
    data: {'name': name, 'email': email, 'phone': phone, 'password': password},
  );

  @override
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final json = await _client.post(
      '/auth/verify-otp',
      data: {'phone': phone, 'code': code},
    );
    return AuthSessionModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> resendOtp(String phone) =>
      _client.post('/auth/resend-otp', data: {'phone': phone});
}
