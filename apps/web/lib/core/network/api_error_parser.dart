import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:dio/dio.dart';

const _fallbackApiErrorMessage = 'Произошла ошибка. Попробуйте позже.';

const _legacyRateLimitMessage = 'Too many requests, please try again later.';

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
          return _finalizeApiError(
            message: message.trim(),
            code: code,
            statusCode: statusCode,
          );
        }
        if (code != null && code.trim().isNotEmpty) {
          return _finalizeApiError(
            message: _messageForCode(code, statusCode),
            code: code,
            statusCode: statusCode,
          );
        }
      }
      if (err is String && err.trim().isNotEmpty) {
        return _finalizeApiError(
          message: err.trim(),
          statusCode: statusCode,
        );
      }
    }
    return _finalizeApiError(
      message: error.message?.trim().isNotEmpty == true
          ? error.message!.trim()
          : _fallbackApiErrorMessage,
      statusCode: statusCode,
    );
  }
  return const ApiError(message: _fallbackApiErrorMessage);
}

ApiError _finalizeApiError({
  required String message,
  String? code,
  int? statusCode,
}) {
  final normalizedCode = _normalizeRateLimitCode(code, statusCode, message);
  return ApiError(
    message: message,
    code: normalizedCode ?? code,
    statusCode: statusCode,
  );
}

String? _normalizeRateLimitCode(String? code, int? statusCode, String message) {
  if (statusCode == 429 || code == kApiErrorCodeRateLimited) {
    return kApiErrorCodeRateLimited;
  }
  final lower = message.toLowerCase();
  if (lower.contains('too many requests') ||
      lower.contains('слишком много запросов')) {
    return kApiErrorCodeRateLimited;
  }
  return null;
}

String _messageForCode(String code, int? statusCode) {
  if (code == kApiErrorCodeRateLimited || statusCode == 429) {
    return _legacyRateLimitMessage;
  }
  return _fallbackApiErrorMessage;
}
