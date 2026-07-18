import 'package:cryprice_frontend/core/config/google_auth_config.dart';

String? _debugReturnToOverride;

/// App origin for backend redirect completion (`return_to` query param).
String resolveGoogleAuthReturnTo() => _debugReturnToOverride ?? crypriceAppOrigin;

/// Tests only.
void debugSetGoogleAuthReturnToForTesting(String? value) {
  _debugReturnToOverride = value;
}

/// True when [origin] is safe to use as `return_to` (localhost or configured app origin).
bool isAllowedGoogleAuthReturnOrigin(String origin) {
  if (origin.isEmpty) {
    return false;
  }
  final parsed = Uri.tryParse(origin);
  if (parsed == null || (parsed.scheme != 'http' && parsed.scheme != 'https')) {
    return false;
  }
  final host = parsed.host.toLowerCase();
  if (host == 'localhost' || host == '127.0.0.1') {
    return true;
  }
  return origin == crypriceAppOrigin;
}
