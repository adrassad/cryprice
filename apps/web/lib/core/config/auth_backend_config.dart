/// Base URL for `/auth/*` (Google login, refresh, me, logout).
///
/// Set at **compile time** with `--dart-define=AUTH_BACKEND_BASE_URL=...`.
/// This host is intentionally **not** tied to [crypriceBackendBaseUrl] so a custom
/// prices base URL does not redirect auth.
///
/// When the define is empty, a local development default is used. Override for
/// staging or production.
String get authBackendBaseUrl {
  const fromEnv = String.fromEnvironment(
    'AUTH_BACKEND_BASE_URL',
    defaultValue: '',
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
