import 'dart:async';

import 'package:cryprice_frontend/core/navigation/app_section.dart';
import 'package:cryprice_frontend/core/navigation/push_navigation_bridge.dart';
import 'package:cryprice_frontend/features/push_notifications/data/platforms/push_messaging_stub.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/entities/push_notification_intent.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/entities/push_platform.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/repositories/push_token_repository.dart';
import 'package:cryprice_frontend/features/push_notifications/data/platforms/push_service_worker_click_listener_stub.dart';
import 'package:cryprice_frontend/features/push_notifications/presentation/push_notification_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPushTokenRepository extends Mock implements PushTokenRepository {}

class MockPushMessagingPlatform extends Mock implements PushMessagingPlatform {}

class _RecordingBridge implements PushNavigationBridge {
  int alertsOpens = 0;
  String? lastAlertId;

  @override
  void openPortfolio() {}

  @override
  void openAlerts({String? alertId}) {
    alertsOpens++;
    lastAlertId = alertId;
  }
}

class _TestSwClickListener extends PushServiceWorkerClickListener {
  _TestSwClickListener() : _controller = StreamController<String>.broadcast();

  final StreamController<String> _controller;

  @override
  Stream<String> get onDeepLinkClick => _controller.stream;

  void emitDeepLink(String deepLink) {
    _controller.add(deepLink);
  }
}

void main() {
  late MockPushMessagingPlatform messaging;
  late MockPushTokenRepository tokenRepository;
  late _RecordingBridge bridge;
  late _TestSwClickListener swClickListener;
  late PushNotificationCoordinator coordinator;

  setUpAll(() {
    registerFallbackValue(PushPlatform.android);
  });

  setUp(() {
    messaging = MockPushMessagingPlatform();
    tokenRepository = MockPushTokenRepository();
    bridge = _RecordingBridge();
    swClickListener = _TestSwClickListener();
    coordinator = PushNotificationCoordinator(
      messagingPlatform: messaging,
      tokenRepository: tokenRepository,
      navigationBridge: bridge,
      serviceWorkerClickListener: swClickListener,
    );

    when(() => messaging.configureForegroundPresentation()).thenAnswer((_) async {});
    when(() => messaging.getInitialMessage()).thenAnswer((_) async => null);
    when(() => messaging.onMessage).thenAnswer((_) => const Stream<Map<String, String>>.empty());
    when(() => messaging.onMessageOpenedApp)
        .thenAnswer((_) => const Stream<Map<String, String>>.empty());
    when(() => messaging.onTokenRefresh).thenAnswer((_) => const Stream<String>.empty());
    when(() => messaging.requestPermission()).thenAnswer((_) async => true);
    when(() => messaging.getToken()).thenAnswer((_) async => 'token-a');
    when(() => tokenRepository.readLastRegisteredToken()).thenAnswer((_) async => null);
    when(
      () => tokenRepository.registerToken(
        token: 'token-a',
        platform: PushPlatform.current(),
      ),
    ).thenAnswer((_) async {});
    when(() => tokenRepository.unregisterToken('token-a')).thenAnswer((_) async {});
  });

  test('onAuthenticated registers token', () async {
    await coordinator.onAuthenticated();

    verify(
      () => tokenRepository.registerToken(
        token: 'token-a',
        platform: PushPlatform.current(),
      ),
    ).called(1);
  });

  test('onAuthenticated skips duplicate token registration', () async {
    when(() => tokenRepository.readLastRegisteredToken()).thenAnswer((_) async => 'token-a');

    await coordinator.onAuthenticated();

    verifyNever(
      () => tokenRepository.registerToken(
        token: 'token-a',
        platform: PushPlatform.current(),
      ),
    );
  });

  test('onLogout unregisters cached token', () async {
    when(() => tokenRepository.readLastRegisteredToken()).thenAnswer((_) async => 'token-a');

    await coordinator.onLogout();

    verify(() => tokenRepository.unregisterToken('token-a')).called(1);
  });

  test('initialize emits one onAlertReceived event per foreground push', () async {
    final messageController = StreamController<Map<String, String>>.broadcast();
    when(() => messaging.onMessage).thenAnswer((_) => messageController.stream);

    final received = <PushNotificationIntent>[];
    final subscription = coordinator.onAlertReceived.listen(received.add);

    await coordinator.initialize();

    messageController.add(const {
      'type': 'risk_news_alert',
      'alert_id': '42',
    });
    await Future<void>.delayed(Duration.zero);

    expect(received, hasLength(1));
    expect(received.single.type, 'risk_news_alert');
    expect(received.single.alertId, '42');
    expect(received.single.targetSection, AppSection.alerts);

    await subscription.cancel();
    await messageController.close();
  });

  test('initialize ignores foreground push without routable type', () async {
    final messageController = StreamController<Map<String, String>>.broadcast();
    when(() => messaging.onMessage).thenAnswer((_) => messageController.stream);

    final received = <PushNotificationIntent>[];
    final subscription = coordinator.onAlertReceived.listen(received.add);

    await coordinator.initialize();

    messageController.add(const {'alert_id': '42'});
    await Future<void>.delayed(Duration.zero);

    expect(received, isEmpty);

    await subscription.cancel();
    await messageController.close();
  });

  test('defers background routing until markRouteHandlerReady', () async {
    final openedController = StreamController<Map<String, String>>.broadcast();
    when(() => messaging.onMessageOpenedApp).thenAnswer((_) => openedController.stream);

    await coordinator.initialize();

    openedController.add(const {
      'type': 'risk_news_alert',
      'alert_id': '5',
    });
    await Future<void>.delayed(Duration.zero);
    expect(bridge.alertsOpens, 0);

    coordinator.markRouteHandlerReady();
    expect(bridge.alertsOpens, 1);
    expect(bridge.lastAlertId, '5');

    await openedController.close();
  });

  test('service worker deep link routes through router once handler is ready', () async {
    await coordinator.initialize();
    coordinator.markRouteHandlerReady();

    swClickListener.emitDeepLink('https://app.cryprice.dev/#/alerts?alert_id=88');
    await Future<void>.delayed(Duration.zero);

    expect(bridge.alertsOpens, 1);
    expect(bridge.lastAlertId, '88');
  });

  test('routeFromDeepLink is ignored when handler is not ready then flushed once', () async {
    coordinator.routeFromDeepLink('https://app.cryprice.dev/#/alerts?alert_id=11');
    expect(bridge.alertsOpens, 0);

    coordinator.markRouteHandlerReady();
    expect(bridge.alertsOpens, 1);
    expect(bridge.lastAlertId, '11');

    coordinator.markRouteHandlerReady();
    expect(bridge.alertsOpens, 1);
  });
}
