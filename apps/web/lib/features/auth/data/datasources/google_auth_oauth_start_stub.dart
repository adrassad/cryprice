import 'package:cryprice_frontend/core/config/auth_backend_config.dart';
import 'package:cryprice_frontend/core/config/google_auth_redirect_urls.dart';

String? debugLastGoogleOAuthStartUrl;
int debugStartGoogleOAuthSignInCalls = 0;

/// Navigates the browser to backend OAuth start (Safari/iOS same-tab flow).
Future<void> startGoogleOAuthSignIn(String returnTo) async {
  debugStartGoogleOAuthSignInCalls++;
  debugLastGoogleOAuthStartUrl = buildGoogleOAuthStartUrl(
    apiBaseUrl: authBackendBaseUrl,
    returnTo: returnTo,
  );
}

/// Tests only.
void resetGoogleOAuthSignInTestHooks() {
  debugStartGoogleOAuthSignInCalls = 0;
  debugLastGoogleOAuthStartUrl = null;
}
