/// Normalized backend rate-limit code (`429` / `{ error: { code: "RATE_LIMITED" } }`).
const String kApiErrorCodeRateLimited = 'RATE_LIMITED';

class ApiError implements Exception {
  const ApiError({
    required this.message,
    this.code,
    this.statusCode,
  });

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => 'ApiError($statusCode, $code, $message)';
}
