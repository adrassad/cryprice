import 'package:cryprice_frontend/core/web/auth_stale_recovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gis_error=cancelled suggests auth reload', () {
    expect(
      shouldSuggestAuthStaleRecovery(
        redirectError: 'cancelled',
        exchangeAttempted: false,
        authenticated: false,
      ),
      isTrue,
    );
  });

  test('gis_exchange without successful auth suggests reload', () {
    expect(
      shouldSuggestAuthStaleRecovery(
        exchangeCode: 'one-time-code',
        exchangeAttempted: true,
        authenticated: false,
        authErrorMessage: 'Auth failed',
      ),
      isTrue,
    );
  });

  test('successful auth does not suggest reload', () {
    expect(
      shouldSuggestAuthStaleRecovery(
        exchangeCode: 'one-time-code',
        exchangeAttempted: true,
        authenticated: true,
      ),
      isFalse,
    );
  });

  test('readAuthRedirectParamsFromUri reads gis query params', () {
    final params = readAuthRedirectParamsFromUri(
      Uri.parse('https://app.cryprice.dev/?gis_error=cancelled'),
    );
    expect(params.redirectError, 'cancelled');
    expect(params.exchangeCode, isNull);
  });
}
