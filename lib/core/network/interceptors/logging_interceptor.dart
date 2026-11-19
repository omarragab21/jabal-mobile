import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Prints requests/responses in debug mode only. The Authorization header
/// is never logged.
class AppLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('--> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log('<-- ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      '<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri} '
      '(${err.type.name})',
    );
    handler.next(err);
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[HTTP] $message');
  }
}
