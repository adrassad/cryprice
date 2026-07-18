import 'dart:async';

/// No-op on non-web platforms and in VM tests.
class PushServiceWorkerClickListener {
  PushServiceWorkerClickListener();

  Stream<String> get onDeepLinkClick => const Stream<String>.empty();

  void start() {}

  Future<void> dispose() async {}
}
