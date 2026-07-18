/// Cross-platform auth-flow guard (web: sessionStorage; VM: in-memory stub).
library;

export 'auth_flow_guard_stub.dart'
    if (dart.library.js_interop) 'auth_flow_guard_web.dart';
