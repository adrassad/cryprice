import 'dart:async';

import 'package:cryprice_frontend/core/config/push_config.dart';
import 'package:cryprice_frontend/core/navigation/push_navigation_bridge.dart';
import 'package:cryprice_frontend/features/push_notifications/data/platforms/push_launch_deep_link.dart';
import 'package:cryprice_frontend/features/push_notifications/data/platforms/push_service_worker_click_listener.dart';
import 'package:cryprice_frontend/features/push_notifications/data/platforms/push_messaging_platform.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/entities/push_notification_intent.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/entities/push_platform.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/repositories/push_token_repository.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/services/push_notification_router.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class PushNotificationCoordinator {
  PushNotificationCoordinator({
    required PushMessagingPlatform messagingPlatform,
    required PushTokenRepository tokenRepository,
    required PushNavigationBridge navigationBridge,
    PushServiceWorkerClickListener? serviceWorkerClickListener,
  })  : _messaging = messagingPlatform,
        _tokenRepository = tokenRepository,
        _router = PushNotificationRouter(navigationBridge: navigationBridge),
        _serviceWorkerClickListener =
            serviceWorkerClickListener ?? PushServiceWorkerClickListener();

  final PushMessagingPlatform _messaging;
  final PushTokenRepository _tokenRepository;
  final PushNotificationRouter _router;
  final PushServiceWorkerClickListener _serviceWorkerClickListener;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final StreamController<PushNotificationIntent> _alertReceivedController =
      StreamController<PushNotificationIntent>.broadcast();
  bool _initialized = false;
  bool _authenticated = false;
  bool _tokenRefreshListenerRegistered = false;
  bool _routeHandlerReady = false;
  PushNotificationIntent? _pendingRouteIntent;

  /// Foreground push receipts parsed for inbox refresh and future UI hooks.
  Stream<PushNotificationIntent> get onAlertReceived =>
      _alertReceivedController.stream;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    _subscriptions.add(
      _messaging.onMessage.listen(_handleForegroundMessage),
    );

    _subscriptions.add(
      _messaging.onMessageOpenedApp.listen(_enqueueRouteFromData),
    );

    _serviceWorkerClickListener.start();
    _subscriptions.add(
      _serviceWorkerClickListener.onDeepLinkClick.listen(routeFromDeepLink),
    );

    final launchDeepLink = readLaunchNotificationDeepLink();
    if (launchDeepLink != null) {
      routeFromDeepLink(launchDeepLink);
      clearLaunchNotificationDeepLinkFromUrl();
    }

    if (!PushConfig.isFirebaseConfigured) {
      debugPrint('[Push] skipped — Firebase dart-defines not configured');
      return;
    }

    await _messaging.configureForegroundPresentation();

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _enqueueRouteFromData(initial);
    }
  }

  /// Called from [AppShell] after [PushNavigationBridge] is bound.
  void markRouteHandlerReady() {
    _routeHandlerReady = true;
    _flushPendingRouteIntent();
  }

  void routeFromDeepLink(String deepLink) {
    _enqueueRoute(PushNotificationIntent.fromDeepLink(deepLink));
  }

  void _enqueueRouteFromData(Map<String, String> data) {
    _enqueueRoute(PushNotificationIntent.fromData(data));
  }

  void _enqueueRoute(PushNotificationIntent? intent) {
    if (intent == null) {
      return;
    }
    _pendingRouteIntent = intent;
    _flushPendingRouteIntent();
  }

  void _flushPendingRouteIntent() {
    if (!_routeHandlerReady || _pendingRouteIntent == null) {
      return;
    }

    final intent = _pendingRouteIntent!;
    _pendingRouteIntent = null;
    _router.routeIntent(intent);
  }

  void _handleForegroundMessage(Map<String, String> data) {
    final intent = PushNotificationIntent.fromData(data);
    if (intent == null || _alertReceivedController.isClosed) {
      return;
    }
    _alertReceivedController.add(intent);
  }

  Future<void> onAuthenticated() async {
    _authenticated = true;
    await _registerCurrentToken();
    if (!_tokenRefreshListenerRegistered) {
      _tokenRefreshListenerRegistered = true;
      _subscriptions.add(
        _messaging.onTokenRefresh.listen((token) async {
          if (!_authenticated || token.isEmpty) {
            return;
          }
          await _registerToken(token);
        }),
      );
    }
  }

  Future<String?> readCachedTokenForLogout() {
    return _tokenRepository.readLastRegisteredToken();
  }

  Future<void> onLogout() async {
    _authenticated = false;
    final last = await _tokenRepository.readLastRegisteredToken();
    if (last == null || last.isEmpty) {
      return;
    }
    try {
      await _tokenRepository.unregisterToken(last);
    } on Object catch (e) {
      debugPrint('[Push] unregister failed: $e');
    }
  }

  Future<void> _registerCurrentToken() async {
    final granted = await _messaging.requestPermission();
    if (!granted) {
      debugPrint('[Push] notification permission not granted');
      return;
    }
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }
    await _registerToken(token);
  }

  Future<void> _registerToken(String token) async {
    final last = await _tokenRepository.readLastRegisteredToken();
    if (last == token) {
      return;
    }
    try {
      await _tokenRepository.registerToken(
        token: token,
        platform: PushPlatform.current(),
      );
      debugPrint('[Push] token registered (${PushPlatform.current().apiValue})');
    } on Object catch (e) {
      debugPrint('[Push] token registration failed: $e');
    }
  }

  Future<void> dispose() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    await _serviceWorkerClickListener.dispose();
  }
}
