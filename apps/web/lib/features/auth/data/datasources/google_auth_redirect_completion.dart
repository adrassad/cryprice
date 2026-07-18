/// Reads GIS redirect return parameters from the current URL (web only).
library;

export 'google_auth_redirect_completion_stub.dart'
    if (dart.library.js_interop) 'google_auth_redirect_completion_web.dart';
