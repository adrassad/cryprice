import 'package:cryprice_frontend/core/config/auth_backend_config.dart';
import 'package:cryprice_frontend/core/config/google_auth_redirect_urls.dart';
import 'package:cryprice_frontend/core/config/google_auth_return_to.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => debugSetGoogleAuthReturnToForTesting(null));

  test('buildGoogleOAuthStartUrl URL-encodes return_to', () {
    expect(
      buildGoogleOAuthStartUrl(
        apiBaseUrl: authBackendBaseUrl,
        returnTo: 'https://app.cryprice.dev',
      ),
      'https://api.cryprice.dev/auth/google/oauth/start'
      '?return_to=https%3A%2F%2Fapp.cryprice.dev',
    );
  });

  test('buildGoogleOAuthStartUrl uses oauth/start not legacy redirect/start', () {
    final url = buildGoogleOAuthStartUrl(
      apiBaseUrl: authBackendBaseUrl,
      returnTo: 'https://app.cryprice.dev',
    );
    expect(url, contains('/auth/google/oauth/start'));
    expect(url, isNot(contains('/auth/google/redirect/start')));
  });

  test('buildGoogleRedirectStartUrl URL-encodes return_to (legacy GIS)', () {
    expect(
      buildGoogleRedirectStartUrl(
        apiBaseUrl: authBackendBaseUrl,
        returnTo: 'https://app.cryprice.dev',
      ),
      'https://api.cryprice.dev/auth/google/redirect/start'
      '?return_to=https%3A%2F%2Fapp.cryprice.dev',
    );
  });

  test('resolveGoogleAuthReturnTo defaults to configured app origin', () {
    expect(resolveGoogleAuthReturnTo(), 'https://app.cryprice.dev');
  });

  test('isAllowedGoogleAuthReturnOrigin allows localhost and app origin', () {
    expect(isAllowedGoogleAuthReturnOrigin('http://localhost:8080'), isTrue);
    expect(isAllowedGoogleAuthReturnOrigin('https://app.cryprice.dev'), isTrue);
    expect(isAllowedGoogleAuthReturnOrigin('https://evil.example'), isFalse);
  });
}
