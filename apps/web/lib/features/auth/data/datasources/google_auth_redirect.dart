/// LEGACY GIS redirect sign-in (`/auth/google/redirect/start`). Unused in production Web login.
library;

export 'google_auth_redirect_stub.dart'
    if (dart.library.js_interop) 'google_auth_redirect_web.dart';
