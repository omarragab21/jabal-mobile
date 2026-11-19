import 'package:equatable/equatable.dart';

import 'exceptions.dart';

/// Domain-level errors. The domain/presentation layers only know [Failure],
/// never Dio or [AppException].
sealed class Failure extends Equatable {
  const Failure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];

  /// Maps a data-layer exception to a domain failure.
  factory Failure.fromException(AppException e) => switch (e) {
    NetworkException() => NetworkFailure(e.message),
    TimeoutAppException() => NetworkFailure(e.message),
    UnauthorizedException() => UnauthorizedFailure(e.message),
    ServerException() => ServerFailure(e.message, statusCode: e.statusCode),
    NotFoundException() => NotFoundFailure(e.message),
    LocationPermissionException() => LocationPermissionFailure(e.message),
    LocationDisabledException() => LocationDisabledFailure(e.message),
    CacheException() => CacheFailure(e.message),
    CancelledException() => UnknownFailure(e.message),
    UnknownException() => UnknownFailure(e.message),
  };
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Check your internet connection']);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired'])
    : super(statusCode: 401);
}

/// The user did not allow the app to read the device location.
class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure([
    super.message = 'Location permission denied',
  ]);
}

/// Location services are switched off on the device.
class LocationDisabledFailure extends Failure {
  const LocationDisabledFailure([super.message = 'Location services are off']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']) : super(statusCode: 404);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}

/// Auth-specific business failures. They are produced by the auth
/// repository (mapped from server error codes) so the UI can show a
/// localized message per case instead of a raw server string.
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Invalid credentials']);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([super.message = 'User not found']);
}

class PhoneAlreadyRegisteredFailure extends Failure {
  const PhoneAlreadyRegisteredFailure([
    super.message = 'Phone already registered',
  ]);
}

class InvalidOtpFailure extends Failure {
  const InvalidOtpFailure([super.message = 'Invalid verification code']);
}

/// The account exists but is not allowed to sign in right now.
class AccountBlockedFailure extends Failure {
  const AccountBlockedFailure([super.message = 'Account blocked'])
    : super(statusCode: 403);
}

/// A discount code the customer typed that does not exist, expired, or does
/// not apply to this cart.
class InvalidPromoCodeFailure extends Failure {
  const InvalidPromoCodeFailure([super.message = 'Invalid promo code']);
}
