import 'package:cryprice_frontend/core/web/app_cache_reset_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app cache reset is not supported on VM test host', () {
    expect(isAppCacheResetSupported, isFalse);
  });

  test('resetAppCache is a no-op when unsupported', () async {
    var cleared = false;
    await resetAppCache(clearAuthTokens: () async {
      cleared = true;
    });
    expect(cleared, isFalse);
  });
}
