import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Dio interceptor that logs request/response details in debug mode.
///
/// Provides structured, color-coded console output for easier debugging.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌─── REQUEST ───────────────────────────────')
      ..writeln('│ ${options.method.toUpperCase()} ${options.uri}')
      ..writeln('│ Headers: ${options.headers}');

    if (options.data != null) {
      buffer.writeln('│ Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query: ${options.queryParameters}');
    }
    buffer.writeln('└───────────────────────────────────────────');

    developer.log(buffer.toString(), name: 'API');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌─── RESPONSE ──────────────────────────────')
      ..writeln('│ ${response.statusCode} ${response.requestOptions.uri}')
      ..writeln('│ Data: ${_truncate(response.data.toString(), 500)}')
      ..writeln('└───────────────────────────────────────────');

    developer.log(buffer.toString(), name: 'API');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌─── ERROR ─────────────────────────────────')
      ..writeln('│ ${err.type.name}: ${err.message}')
      ..writeln('│ ${err.requestOptions.method} ${err.requestOptions.uri}');

    if (err.response != null) {
      buffer.writeln('│ Status: ${err.response?.statusCode}');
      buffer.writeln('│ Data: ${_truncate(err.response?.data.toString() ?? '', 300)}');
    }
    buffer.writeln('└───────────────────────────────────────────');

    developer.log(buffer.toString(), name: 'API', level: 1000);
    handler.next(err);
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}… (truncated)';
  }
}
