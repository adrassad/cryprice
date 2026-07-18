/// Non-web stub: app cache reset is unavailable.
Future<void> resetAppCache({required Future<void> Function() clearAuthTokens}) async {}

bool get isAppCacheResetSupported => false;
