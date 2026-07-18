/// Chooses Google Sign-In UX (popup vs redirect) for the current browser.
library;

export 'google_auth_browser_policy_stub.dart'
    if (dart.library.js_interop) 'google_auth_browser_policy_web.dart';
