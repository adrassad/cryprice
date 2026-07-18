import 'package:cryprice_frontend/core/web/google_auth_browser_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => debugSetGoogleAuthUxMode(null));

  test('defaults to backend OAuth redirect mode', () {
    expect(preferredGoogleAuthUxMode(), GoogleAuthUxMode.redirect);
    expect(shouldUseGoogleRedirectAuth(), isTrue);
  });

  test('legacy popup override remains available for tests', () {
    debugSetGoogleAuthUxMode(GoogleAuthUxMode.popup);
    expect(preferredGoogleAuthUxMode(), GoogleAuthUxMode.popup);
    expect(shouldUseGoogleRedirectAuth(), isFalse);
  });
}
