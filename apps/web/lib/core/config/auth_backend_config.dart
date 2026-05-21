import 'package:cryprice_frontend/core/config/cryprice_backend_config.dart';

/// Base URL for `/auth/*` (Google login, refresh, me, logout).
/// Same host as [crypriceBackendBaseUrl] — override via
/// `--dart-define=CRYPRICE_BACKEND_BASE_URL=...` (local or prod).
String get authBackendBaseUrl => crypriceBackendBaseUrl;
