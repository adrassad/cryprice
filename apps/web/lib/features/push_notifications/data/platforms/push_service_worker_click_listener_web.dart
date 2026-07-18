import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

const _notificationClickMessageType = 'cryprice:notification-click';

/// Listens for `{ type: 'cryprice:notification-click', deep_link }` from the FCM SW.
class PushServiceWorkerClickListener {
  PushServiceWorkerClickListener()
      : _controller = StreamController<String>.broadcast();

  final StreamController<String> _controller;
  JSFunction? _listener;
  var _started = false;

  Stream<String> get onDeepLinkClick => _controller.stream;

  void start() {
    if (_started) {
      return;
    }
    _started = true;

    _listener = ((web.Event event) {
      if (event is! web.MessageEvent) {
        return;
      }
      final data = event.data;
      if (data == null || !data.isA<JSObject>()) {
        return;
      }

      final payload = data as JSObject;
      final type = (payload['type'] as JSString?)?.toDart;
      if (type != _notificationClickMessageType) {
        return;
      }

      final deepLink = (payload['deep_link'] as JSString?)?.toDart.trim();
      if (deepLink == null || deepLink.isEmpty) {
        return;
      }

      _controller.add(deepLink);
    }).toJS;

    web.window.navigator.serviceWorker.addEventListener('message', _listener!);
  }

  Future<void> dispose() async {
    if (_listener != null) {
      web.window.navigator.serviceWorker.removeEventListener('message', _listener!);
      _listener = null;
    }
    await _controller.close();
  }
}
