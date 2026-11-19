/// Exceptions thrown by the data layer (network / remote data sources).
/// Repositories catch these and convert them into [Failure]s.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class TimeoutAppException extends AppException {
  const TimeoutAppException([super.message = 'Connection timed out']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized'])
    : super(statusCode: 401);
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found'])
    : super(statusCode: 404);
}

class LocationPermissionException extends AppException {
  const LocationPermissionException([
    super.message = 'Location permission denied',
  ]);
}

class LocationDisabledException extends AppException {
  const LocationDisabledException([
    super.message = 'Location services are off',
  ]);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Local storage error']);
}

class CancelledException extends AppException {
  const CancelledException([super.message = 'Request cancelled']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Something went wrong']);
}
