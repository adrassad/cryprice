import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:dio/dio.dart';

const _fallbackApiErrorMessage = 'Произошла ошибка. Попробуйте позже.';

ApiError parseApiError(Object error) {
  if (error is ApiError) {
    return error;
  }
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    if (data is Map) {
      final map = data.cast<String, Object?>();
      final err = map['error'];
      if (err is Map) {
        final errMap = err.cast<String, Object?>();
        final message = errMap['message']?.toString();
        final code = errMap['code']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          return ApiError(
            message: message.trim(),
            code: code,
            statusCode: statusCode,
          );
        }
      }
      if (err is String && err.trim().isNotEmpty) {
        return ApiError(message: err.trim(), statusCode: statusCode);
      }
    }
    return ApiError(
      message: error.message?.trim().isNotEmpty == true
          ? error.message!.trim()
          : _fallbackApiErrorMessage,
      statusCode: statusCode,
    );
  }
  return const ApiError(message: _fallbackApiErrorMessage);
}
