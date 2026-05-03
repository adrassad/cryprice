class AuthApiException implements Exception {
  AuthApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => 'AuthApiException($code, $message)';
}
