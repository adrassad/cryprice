// Single source of truth for the Cryprice HTTP API base used by [OffchainOnchainPricesClient].
//
// Set at **compile time** with:
//   flutter run --dart-define=CRYPRICE_BACKEND_BASE_URL=http://127.0.0.1:3000
// Android emulator → host machine: use http://10.0.2.2:3000
//
// When the define is empty, a local development default is used. Override to point
// at a hosted API.
String get crypriceBackendBaseUrl {
  const fromEnv = String.fromEnvironment(
    'CRYPRICE_BACKEND_BASE_URL',
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
