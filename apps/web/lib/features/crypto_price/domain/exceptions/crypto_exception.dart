enum CryptoErrorCode { noInternet, fetchFailed, rateLimited, unknown }

class CryptoException implements Exception {
  final CryptoErrorCode code;
  final String? message;

  CryptoException(this.code, [this.message]);
}
