import 'package:cryprice_frontend/core/config/google_auth_config.dart';

/// Whether the user should reload after a stale auth bundle or failed GIS/OAuth return.
bool shouldSuggestAuthStaleRecovery({
  String? redirectError,
  String? exchangeCode,
  required bool exchangeAttempted,
  required bool authenticated,
  String? authErrorMessage,
}) {
  if (redirectError == 'cancelled') {
    return true;
  }

  if (redirectError != null && redirectError.isNotEmpty) {
    return true;
  }

  if (exchangeCode != null &&
      exchangeCode.isNotEmpty &&
      exchangeAttempted &&
      !authenticated) {
    return true;
  }

  if (authErrorMessage == 'cancelled') {
    return true;
  }

  return false;
}

/// Reads redirect params from [Uri.base] before they are stripped from the URL.
({String? exchangeCode, String? redirectError}) readAuthRedirectParamsFromUri(
  Uri uri,
) {
  return (
    exchangeCode: uri.queryParameters[kGoogleAuthExchangeQueryKey],
    redirectError: uri.queryParameters[kGoogleAuthErrorQueryKey],
  );
}
