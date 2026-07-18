import 'dart:async';
import 'dart:io';

import 'package:cryprice_frontend/core/di/di.dart';
import 'package:cryprice_frontend/core/navigation/push_navigation_bridge.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_alert_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_all_alerts_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:cryprice_frontend/features/push_notifications/data/platforms/push_messaging_stub.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/repositories/push_token_repository.dart';
import 'package:cryprice_frontend/features/push_notifications/presentation/push_notification_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPushTokenRepository extends Mock implements PushTokenRepository {}

class MockPushMessagingPlatform extends Mock implements PushMessagingPlatform {}

class MockGetAlertsUseCase extends Mock implements GetAlertsUseCase {}

class MockMarkAlertReadUseCase extends Mock implements MarkAlertReadUseCase {}

class MockMarkAllAlertsReadUseCase extends Mock implements MarkAllAlertsReadUseCase {}

void main() {
  late MockPushMessagingPlatform messaging;
  late MockPushTokenRepository tokenRepository;
  late MockGetAlertsUseCase getAlertsUseCase;
  late StreamController<Map<String, String>> messageController;
  late PushNotificationCoordinator coordinator;
  late AlertsInboxCubit alertsCubit;
  StreamSubscription<dynamic>? inboxRefreshSubscription;

  setUp(() async {
    await di.reset();

    messaging = MockPushMessagingPlatform();
    tokenRepository = MockPushTokenRepository();
    getAlertsUseCase = MockGetAlertsUseCase();
    messageController = StreamController<Map<String, String>>.broadcast();

    when(() => messaging.configureForegroundPresentation()).thenAnswer((_) async {});
    when(() => messaging.getInitialMessage()).thenAnswer((_) async => null);
    when(() => messaging.onMessage).thenAnswer((_) => messageController.stream);
    when(() => messaging.onMessageOpenedApp)
        .thenAnswer((_) => const Stream<Map<String, String>>.empty());
    when(() => messaging.onTokenRefresh).thenAnswer((_) => const Stream<String>.empty());

    when(() => getAlertsUseCase.execute()).thenAnswer((_) async => []);

    alertsCubit = AlertsInboxCubit(
      getAlertsUseCase: getAlertsUseCase,
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );

    di.registerLazySingleton<PushTokenRepository>(() => tokenRepository);
    di.registerLazySingleton<PushMessagingPlatform>(() => messaging);
    di.registerLazySingleton(MutablePushNavigationBridge.new);
    di.registerLazySingleton<PushNavigationBridge>(
      () => di<MutablePushNavigationBridge>(),
    );
    di.registerLazySingleton(
      () => PushNotificationCoordinator(
        messagingPlatform: di<PushMessagingPlatform>(),
        tokenRepository: di<PushTokenRepository>(),
        navigationBridge: di<PushNavigationBridge>(),
      ),
    );

    coordinator = di<PushNotificationCoordinator>();
    await coordinator.initialize();

    inboxRefreshSubscription = coordinator.onAlertReceived.listen((_) {
      unawaited(alertsCubit.refresh());
    });
  });

  tearDown(() async {
    await inboxRefreshSubscription?.cancel();
    inboxRefreshSubscription = null;
    await messageController.close();
    await alertsCubit.close();
    await di.reset();
  });

  test('AppShell wiring refreshes inbox once per foreground push', () async {
    messageController.add(const {
      'type': 'risk_news_alert',
      'alert_id': '7',
    });
    await Future<void>.delayed(Duration.zero);

    verify(() => getAlertsUseCase.execute()).called(1);
  });

  test('AppShell wiring does not refresh after subscription is cancelled', () async {
    await inboxRefreshSubscription?.cancel();
    inboxRefreshSubscription = null;

    messageController.add(const {
      'type': 'risk_news_alert',
      'alert_id': '7',
    });
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => getAlertsUseCase.execute());
  });

  test('AppShell source subscribes to coordinator onAlertReceived', () {
    final src = File('lib/core/shell/app_shell.dart').readAsStringSync();
    expect(src.contains('_pushCoordinator.onAlertReceived.listen'), isTrue);
    expect(src.contains('_alertsInboxCubit.refresh()'), isTrue);
    expect(src.contains('_pushCoordinator.markRouteHandlerReady()'), isTrue);
    expect(src.contains('_pushInboxRefreshSubscription?.cancel()'), isTrue);
  });
}
