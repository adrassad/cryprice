import 'package:cryprice_frontend/core/config/google_auth_config.dart';
import 'package:web/web.dart' as web;

/// One-time exchange code after backend redirect (never raw tokens).
String? readGoogleAuthExchangeCode() {
  final code = Uri.base.queryParameters[kGoogleAuthExchangeQueryKey];
  if (code == null || code.isEmpty) {
    return null;
  }
  return code;
}

/// Error code/message from backend redirect when auth failed.
String? readGoogleAuthRedirectError() {
  final err = Uri.base.queryParameters[kGoogleAuthErrorQueryKey];
  if (err == null || err.isEmpty) {
    return null;
  }
  return err;
}

/// Removes redirect query params from the address bar.
void clearGoogleAuthRedirectQueryParams() {
  final uri = Uri.base;
  if (!uri.queryParameters.containsKey(kGoogleAuthExchangeQueryKey) &&
      !uri.queryParameters.containsKey(kGoogleAuthErrorQueryKey)) {
    return;
  }
  final params = Map<String, String>.from(uri.queryParameters)
    ..remove(kGoogleAuthExchangeQueryKey)
    ..remove(kGoogleAuthErrorQueryKey);
  final clean = uri.replace(queryParameters: params.isEmpty ? null : params);
  web.window.history.replaceState(null, '', clean.toString());
}
