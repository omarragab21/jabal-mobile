import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';
import 'data/datasources/auth_local_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/mock_auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_current_session.dart';
import 'domain/usecases/login.dart';
import 'domain/usecases/logout.dart';
import 'domain/usecases/register.dart';
import 'domain/usecases/resend_otp.dart';
import 'domain/usecases/verify_otp.dart';
import 'domain/validators/auth_validation.dart';
import 'domain/validators/phone_number_validator.dart';
import 'data/validators/lib_phone_number_validator.dart';
import 'presentation/gate/auth_gate_cubit.dart';
import 'presentation/gate/auth_gate_page.dart';
import 'presentation/login/login_cubit.dart';
import 'presentation/login/login_page.dart';
import 'presentation/otp/otp_args.dart';
import 'presentation/otp/otp_cubit.dart';
import 'presentation/otp/otp_page.dart';
import 'presentation/register/register_cubit.dart';
import 'presentation/register/register_page.dart';

/// Wires the auth feature. Pass [remote] to choose the backend:
///
/// ```dart
/// AuthModule(storage)                                   // mock (default)
/// AuthModule(storage, remote: ApiAuthRemoteDataSource(apiClient)) // real API
/// ```
class AuthModule {
  AuthModule(
    LocalStorage storage, {
    AuthRemoteDataSource? remote,
    PhoneNumberValidator phoneValidator = const LibPhoneNumberValidator(),
  }) : _repository = AuthRepositoryImpl(
         remote ?? MockAuthRemoteDataSource(),
         AuthLocalDataSourceImpl(storage),
       ),
       _validation = AuthValidation(phone: phoneValidator);

  final AuthRepository _repository;
  final AuthValidation _validation;

  /// The input rules, shared with the features that edit the same data
  /// (the profile, the address form).
  AuthValidation get validation => _validation;

  /// Exposed so other features (e.g. account) can read the session / log out.
  GetCurrentSession get getCurrentSession => GetCurrentSession(_repository);
  Logout get logout => Logout(_repository);

  Widget gatePage() => BlocProvider(
    create: (_) => AuthGateCubit(GetCurrentSession(_repository))..check(),
    child: const AuthGatePage(),
  );

  Widget loginPage() => BlocProvider(
    create: (_) => LoginCubit(Login(_repository), _validation),
    child: const LoginPage(),
  );

  Widget registerPage() => BlocProvider(
    create: (_) => RegisterCubit(Register(_repository), _validation),
    child: const RegisterPage(),
  );

  Widget otpPage(OtpArgs args) => BlocProvider(
    create: (_) => OtpCubit(
      phone: args.phone,
      verifyOtp: VerifyOtp(_repository),
      resendOtp: ResendOtp(_repository),
      otpValidator: _validation.otp,
    ),
    child: const OtpPage(),
  );
}
