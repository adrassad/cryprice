import 'package:cryprice_frontend/core/config/auth_backend_config.dart';
import 'package:cryprice_frontend/core/config/google_auth_redirect_urls.dart';
import 'package:web/web.dart' as web;

/// Navigates the browser to backend OAuth start (all Web browsers, same-tab flow).
Future<void> startGoogleOAuthSignIn(String returnTo) async {
  final url = buildGoogleOAuthStartUrl(
    apiBaseUrl: authBackendBaseUrl,
    returnTo: returnTo,
  );
  web.window.location.assign(url);
}
