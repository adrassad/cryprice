import 'dart:async';

import 'package:cryprice_frontend/features/push_notifications/data/platforms/push_messaging_stub.dart';

class PushMessagingPlatformImpl extends PushMessagingPlatform {
  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

  @override
  Stream<Map<String, String>> get onMessage => const Stream<Map<String, String>>.empty();

  @override
  Stream<Map<String, String>> get onMessageOpenedApp =>
      const Stream<Map<String, String>>.empty();

  @override
  Future<Map<String, String>?> getInitialMessage() async => null;

  @override
  Future<void> configureForegroundPresentation() async {}

  @override
  Future<void> showForegroundNotification({
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {}
}

PushMessagingPlatform createPushMessagingPlatform() => PushMessagingPlatformImpl();
