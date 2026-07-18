import 'package:cryprice_frontend/core/auth/auth_flow_guard.dart';
import 'package:cryprice_frontend/core/auth/auth_flow_guard_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(clearAuthFlowGuardForTesting);

  test('beginAuthFlow sets active flag', () {
    expect(isAuthFlowInProgress(), isFalse);
    beginAuthFlow();
    expect(isAuthFlowInProgress(), isTrue);
  });

  test('endAuthFlow clears active flag', () {
    beginAuthFlow();
    endAuthFlow();
    expect(isAuthFlowInProgress(), isFalse);
  });

  test('stale auth-flow flag is ignored after timeout', () {
    final expired =
        DateTime.now().millisecondsSinceEpoch - kAuthFlowGuardTimeout.inMilliseconds - 1;
    debugSetAuthFlowStartedAtMsForTesting(expired);
    expect(isAuthFlowInProgress(), isFalse);
  });
}
