import 'dart:async';

/// Platform FCM adapter (mobile / web / test stub).
abstract class PushMessagingPlatform {
  Future<bool> requestPermission();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Stream<Map<String, String>> get onMessage;

  Stream<Map<String, String>> get onMessageOpenedApp;

  Future<Map<String, String>?> getInitialMessage();

  Future<void> configureForegroundPresentation();

  Future<void> showForegroundNotification({
    required String title,
    required String body,
    Map<String, String>? data,
  });
}
