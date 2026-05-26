// Single source of truth for the Cryprice HTTP API base (prices, profile, `/auth/*`).
// Used by [OffchainOnchainPricesClient] and [authBackendBaseUrl].
//
// Default: local API for OSS clone-and-run. For production/staging builds pass:
//   flutter build web --dart-define=CRYPRICE_BACKEND_BASE_URL=https://api.cryprice.dev
// Android emulator → host machine: use http://10.0.2.2:3000
String get crypriceBackendBaseUrl {
  const fromEnv = String.fromEnvironment(
    'CRYPRICE_BACKEND_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );
  final raw = fromEnv.trim();
  if (raw.isEmpty) {
    return 'http://127.0.0.1:3000';
  }
  return _stripTrailingSlashes(raw);
}

String _stripTrailingSlashes(String s) {
  if (s.length <= 1) {
    return s;
  }
  var t = s;
  while (t.endsWith('/')) {
    t = t.substring(0, t.length - 1);
  }
  return t;
}
