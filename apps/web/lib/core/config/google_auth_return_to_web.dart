import 'package:cryprice_frontend/core/config/google_auth_config.dart';
import 'package:cryprice_frontend/core/config/google_auth_return_to_stub.dart'
    show isAllowedGoogleAuthReturnOrigin;
import 'package:web/web.dart' as web;

String? _debugReturnToOverride;

/// Prefers the current browser origin when allowlisted; otherwise [crypriceAppOrigin].
String resolveGoogleAuthReturnTo() {
  if (_debugReturnToOverride != null) {
    return _debugReturnToOverride!;
  }
  final origin = web.window.location.origin;
  if (isAllowedGoogleAuthReturnOrigin(origin)) {
    return origin;
  }
  return crypriceAppOrigin;
}

/// Tests only (web host; VM tests use stub).
void debugSetGoogleAuthReturnToForTesting(String? value) {
  _debugReturnToOverride = value;
}
