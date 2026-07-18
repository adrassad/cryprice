/// Resolves the app origin sent as `return_to` for Google redirect start.
library;

export 'google_auth_return_to_stub.dart'
    if (dart.library.js_interop) 'google_auth_return_to_web.dart';
