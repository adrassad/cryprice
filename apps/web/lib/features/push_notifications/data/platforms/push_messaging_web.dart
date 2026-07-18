import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cryprice_frontend/core/config/push_config.dart';
import 'package:cryprice_frontend/features/push_notifications/data/platforms/push_messaging_stub.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushMessagingWebPlatform extends PushMessagingPlatform {
  PushMessagingWebPlatform({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final StreamController<Map<String, String>> _messageController =
      StreamController<Map<String, String>>.broadcast();
  final StreamController<Map<String, String>> _openedController =
      StreamController<Map<String, String>>.broadcast();
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() {
    if (PushConfig.webVapidKey.isEmpty) {
      debugPrint('[Push][Web] FIREBASE_WEB_VAPID_KEY is not set');
      return Future.value(null);
    }
    return _messaging.getToken(vapidKey: PushConfig.webVapidKey);
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<Map<String, String>> get onMessage => _messageController.stream;

  @override
  Stream<Map<String, String>> get onMessageOpenedApp =>
      _openedController.stream;

  @override
  Future<Map<String, String>?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message == null) {
      return null;
    }
    return _normalizeData(message.data);
  }

  @override
  Future<void> configureForegroundPresentation() async {
    _foregroundSub ??= FirebaseMessaging.onMessage.listen((message) {
      _messageController.add(_normalizeData(message.data));
    });
    _openedSub ??= FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openedController.add(_normalizeData(message.data));
    });
  }

  @override
  Future<void> showForegroundNotification({
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // Web foreground notifications are handled by the browser / FCM SDK.
  }

  Map<String, String> _normalizeData(Map<String, dynamic> raw) {
    return raw.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }
}

PushMessagingPlatform createPushMessagingPlatform() =>
    PushMessagingWebPlatform();
