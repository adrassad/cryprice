import 'package:cryprice_frontend/core/config/auth_backend_config.dart';

/// Web OAuth client id (`--dart-define=GOOGLE_WEB_CLIENT_ID=...`).
String get googleWebClientId {
  const fromEnv = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');
  return fromEnv.trim();
}

/// App origin used for post-login redirects (no trailing slash).
String get crypriceAppOrigin {
  const fromEnv = String.fromEnvironment(
    'CRYPRICE_APP_ORIGIN',
    defaultValue: 'https://app.cryprice.dev',
  );
  final raw = fromEnv.trim();
  if (raw.isEmpty) {
    return 'https://app.cryprice.dev';
  }
  return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
}

/// GIS redirect `login_uri` — Google POSTs credential here (backend must handle).
/// LEGACY GIS callback URI for backend; not called from Flutter Web login.
String get googleRedirectLoginUri => '$authBackendBaseUrl/auth/google/callback';

/// Query param carrying a one-time exchange code (never raw tokens).
const String kGoogleAuthExchangeQueryKey = 'gis_exchange';

/// Query param when redirect auth failed or was cancelled.
const String kGoogleAuthErrorQueryKey = 'gis_error';
