/// Query param for post-login redirect target on OAuth start URLs.
const String kGoogleAuthReturnToQueryKey = 'return_to';

/// Canonical Flutter Web login start URL.
///
/// Production must use `/auth/google/oauth/start` (302 → Google OAuth).
/// Do not use [buildGoogleRedirectStartUrl] for Web login.
String buildGoogleOAuthStartUrl({
  required String apiBaseUrl,
  required String returnTo,
}) {
  return '$apiBaseUrl/auth/google/oauth/start'
      '?$kGoogleAuthReturnToQueryKey=${Uri.encodeComponent(returnTo)}';
}

/// Legacy GIS redirect start URL (`GET /auth/google/redirect/start` → 200 + `g_csrf_token`).
///
/// Not used by production Flutter Web login. Kept for legacy GIS redirect helpers/tests.
String buildGoogleRedirectStartUrl({
  required String apiBaseUrl,
  required String returnTo,
}) {
  return '$apiBaseUrl/auth/google/redirect/start'
      '?$kGoogleAuthReturnToQueryKey=${Uri.encodeComponent(returnTo)}';
}
