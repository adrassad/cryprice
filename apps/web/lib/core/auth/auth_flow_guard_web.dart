import 'package:cryprice_frontend/core/auth/auth_flow_guard_keys.dart';
import 'package:web/web.dart' as web;

/// Marks the start of an interactive Google auth flow.
void beginAuthFlow() {
  final now = DateTime.now().millisecondsSinceEpoch;
  web.window.sessionStorage.setItem(kAuthFlowInProgressKey, 'true');
  web.window.sessionStorage.setItem(kAuthFlowStartedAtKey, '$now');
}

/// Clears the auth-flow guard after success, cancel, or error.
void endAuthFlow() {
  web.window.sessionStorage.removeItem(kAuthFlowInProgressKey);
  web.window.sessionStorage.removeItem(kAuthFlowStartedAtKey);
}

/// True while auth is in progress and the guard has not timed out.
bool isAuthFlowInProgress() {
  if (web.window.sessionStorage.getItem(kAuthFlowInProgressKey) != 'true') {
    return false;
  }
  final startedRaw = web.window.sessionStorage.getItem(kAuthFlowStartedAtKey);
  if (startedRaw == null || startedRaw.isEmpty) {
    return true;
  }
  final started = int.tryParse(startedRaw);
  if (started == null) {
    return true;
  }
  final elapsed = DateTime.now().millisecondsSinceEpoch - started;
  if (elapsed >= kAuthFlowGuardTimeout.inMilliseconds) {
    endAuthFlow();
    return false;
  }
  return true;
}

/// Clears session guard state (tests only).
void clearAuthFlowGuardForTesting() {
  endAuthFlow();
  web.window.sessionStorage.removeItem(kSwReloadPendingKey);
}
