/// Safari/iOS backend OAuth start navigation (web only).
library;

export 'google_auth_oauth_start_stub.dart'
    if (dart.library.js_interop) 'google_auth_oauth_start_web.dart';
