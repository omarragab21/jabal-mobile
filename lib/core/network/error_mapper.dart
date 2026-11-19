import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Single responsibility: translate a [DioException] into an [AppException].
class DioErrorMapper {
  const DioErrorMapper();

  AppException map(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutAppException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const CancelledException();
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401) return const UnauthorizedException();
        return ServerException(_messageFrom(e.response), statusCode: code);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnknownException(e.message ?? 'Something went wrong');
    }
  }

  String _messageFrom(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return response?.statusMessage ?? 'Server error';
  }
}
