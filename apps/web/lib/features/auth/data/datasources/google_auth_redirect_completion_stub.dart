String? _debugExchangeCode;
String? _debugRedirectError;

/// One-time exchange code after backend redirect (never raw tokens).
String? readGoogleAuthExchangeCode() => _debugExchangeCode;

/// Error code/message from backend redirect when auth failed.
String? readGoogleAuthRedirectError() => _debugRedirectError;

/// Removes redirect query params from the address bar.
void clearGoogleAuthRedirectQueryParams() {
  _debugExchangeCode = null;
  _debugRedirectError = null;
}

/// Tests only.
void debugSetGoogleAuthExchangeCodeForTesting(String? code) {
  _debugExchangeCode = code;
}

/// Tests only.
void debugSetGoogleAuthRedirectErrorForTesting(String? error) {
  _debugRedirectError = error;
}
