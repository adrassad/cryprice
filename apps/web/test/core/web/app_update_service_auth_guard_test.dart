import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/core/web/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(clearAuthFlowGuardForTesting);

  test('checkForAppUpdate returns false while auth flow is active', () async {
    beginAuthFlow();
    expect(await checkForAppUpdate(), isFalse);
  });

  test('activatePendingAppUpdate is a no-op while auth flow is active', () async {
    beginAuthFlow();
    await activatePendingAppUpdate();
    expect(isAuthFlowInProgress(), isTrue);
  });

  test('activatePendingAppUpdate runs when auth flow is inactive', () async {
    await activatePendingAppUpdate();
    expect(isAuthFlowInProgress(), isFalse);
  });
}
