import 'dart:async';

import 'package:cryprice_frontend/core/config/push_config.dart';
import 'package:cryprice_frontend/features/push_notifications/data/platforms/push_messaging_stub.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushMessagingMobilePlatform extends PushMessagingPlatform {
  PushMessagingMobilePlatform({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
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
  Future<String?> getToken() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<Map<String, String>> get onMessage => _messageController.stream;

  @override
  Stream<Map<String, String>> get onMessageOpenedApp => _openedController.stream;

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
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) {
          return;
        }
        _openedController.add(<String, String>{'type': payload});
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            PushConfig.androidNotificationChannelId,
            'CryPrice alerts',
            description: 'Health factor and risk news notifications',
            importance: Importance.high,
          ),
        );

    _foregroundSub ??= FirebaseMessaging.onMessage.listen((message) async {
      final data = _normalizeData(message.data);
      _messageController.add(data);
      final notification = message.notification;
      if (notification != null) {
        await showForegroundNotification(
          title: notification.title ?? 'CryPrice',
          body: notification.body ?? '',
          data: data,
        );
      }
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
    final type = data?['type'] ?? 'alert';
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          PushConfig.androidNotificationChannelId,
          'CryPrice alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: type,
    );
  }

  Map<String, String> _normalizeData(Map<String, dynamic> raw) {
    return raw.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
  }
}

PushMessagingPlatform createPushMessagingPlatform() =>
    PushMessagingMobilePlatform();
