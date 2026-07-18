import 'package:cryprice_frontend/core/auth/auth_flow_guard_keys.dart';

bool _inMemoryActive = false;
int? _inMemoryStartedAtMs;

/// Marks the start of an interactive Google auth flow.
void beginAuthFlow() {
  _inMemoryActive = true;
  _inMemoryStartedAtMs = DateTime.now().millisecondsSinceEpoch;
}

/// Clears the auth-flow guard after success, cancel, or error.
void endAuthFlow() {
  _inMemoryActive = false;
  _inMemoryStartedAtMs = null;
}

/// True while auth is in progress and the guard has not timed out.
bool isAuthFlowInProgress() {
  if (!_inMemoryActive) {
    return false;
  }
  final started = _inMemoryStartedAtMs;
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

/// Clears in-memory guard state (tests only).
void clearAuthFlowGuardForTesting() {
  endAuthFlow();
}

/// Backdates guard start time (tests only, stub host).
void debugSetAuthFlowStartedAtMsForTesting(int epochMs) {
  _inMemoryActive = true;
  _inMemoryStartedAtMs = epochMs;
}
