import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/core/web/app_update_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(clearAuthFlowGuardForTesting);

  test('onAuthFlowEndedForAppUpdate is a no-op while auth flow is active', () async {
    beginAuthFlow();
    await onAuthFlowEndedForAppUpdate();
    expect(isAuthFlowInProgress(), isTrue);
  });

  test('onAuthFlowEndedForAppUpdate runs after auth flow ends', () async {
    beginAuthFlow();
    endAuthFlow();
    await onAuthFlowEndedForAppUpdate();
    expect(isAuthFlowInProgress(), isFalse);
  });
}
