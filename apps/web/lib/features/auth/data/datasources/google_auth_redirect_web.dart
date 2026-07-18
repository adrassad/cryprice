import 'package:cryprice_frontend/core/config/auth_backend_config.dart';
import 'package:cryprice_frontend/core/config/google_auth_redirect_urls.dart';
import 'package:cryprice_frontend/core/config/google_auth_return_to.dart';
import 'package:cryprice_frontend/core/config/google_auth_config.dart';
import 'package:google_identity_services_web/id.dart' as gis;
import 'package:web/web.dart' as web;

/// LEGACY: GIS redirect sign-in via `/auth/google/redirect/start` and `renderButton`.
///
/// Not used by production Flutter Web login. Web uses [startGoogleOAuthSignIn] with
/// `/auth/google/oauth/start` instead.
///
/// The page navigates away to Google; completion happens on return via
/// [readGoogleAuthExchangeCode] + [AuthRepository.exchangeGoogleRedirectCode].
Future<void> startGoogleRedirectSignIn() async {
  final clientId = googleWebClientId;
  if (clientId.isEmpty) {
    throw StateError('GOOGLE_WEB_CLIENT_ID is not configured');
  }

  gis.id.initialize(
    gis.IdConfiguration(
      client_id: clientId,
      ux_mode: gis.UxMode.redirect,
      login_uri: Uri.parse(googleRedirectLoginUri),
      auto_select: false,
      cancel_on_tap_outside: false,
    ),
  );

  final existing = web.document.getElementById('cryprice-gis-redirect-host');
  final host = (existing ?? web.document.createElement('div')) as web.HTMLDivElement;
  host.id = 'cryprice-gis-redirect-host';
  host.style.setProperty('position', 'fixed');
  host.style.setProperty('left', '-9999px');
  host.style.setProperty('width', '280px');
  if (existing == null) {
    web.document.body?.appendChild(host);
  }

  gis.id.renderButton(
    host,
    gis.GsiButtonConfiguration(
      type: gis.ButtonType.standard,
      size: gis.ButtonSize.large,
      text: gis.ButtonText.signin_with,
      width: 280,
    ),
  );

  await Future<void>.delayed(const Duration(milliseconds: 150));
  final button = host.querySelector('[role="button"]');
  if (button != null) {
    button.dispatchEvent(
      web.MouseEvent(
        'click',
        web.MouseEventInit(bubbles: true, cancelable: true),
      ),
    );
    return;
  }

  // Backend-hosted start page sets CSRF cookie and owns GIS bootstrap.
  web.window.location.href = buildGoogleRedirectStartUrl(
    apiBaseUrl: authBackendBaseUrl,
    returnTo: resolveGoogleAuthReturnTo(),
  );
}
