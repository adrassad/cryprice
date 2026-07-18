import 'package:cryprice_frontend/features/alerts/domain/entities/health_factor_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/risk_news_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_alert_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_all_alerts_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_error_codes.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_state.dart';
import 'package:cryprice_frontend/core/shell/widgets/shell_alerts_nav_icon.dart';
import 'package:cryprice_frontend/features/alerts/presentation/pages/alerts_inbox_page.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAlertsUseCase extends Mock implements GetAlertsUseCase {}

class MockMarkAlertReadUseCase extends Mock implements MarkAlertReadUseCase {}

class MockMarkAllAlertsReadUseCase extends Mock implements MarkAllAlertsReadUseCase {}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('shows empty state', (tester) async {
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);
    cubit.emit(const AlertsInboxState(status: AlertsInboxStatus.empty));

    await tester.pumpWidget(_app(cubit));

    expect(find.byKey(const Key('alerts_inbox_empty')), findsOneWidget);
    expect(find.text('No alerts yet'), findsOneWidget);
    expect(find.byKey(const Key('alerts_inbox_mark_all_read')), findsNothing);
  });

  testWidgets('shows loading state', (tester) async {
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);
    cubit.emit(const AlertsInboxState(status: AlertsInboxStatus.loading));

    await tester.pumpWidget(_app(cubit));

    expect(find.byKey(const Key('alerts_inbox_loading')), findsOneWidget);
    expect(find.text('Loading alerts…'), findsOneWidget);
    expect(find.byKey(const Key('alerts_inbox_mark_all_read')), findsNothing);
  });

  testWidgets('shows network error on full-page failure', (tester) async {
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);
    cubit.emit(
      const AlertsInboxState(
        status: AlertsInboxStatus.failure,
        errorCode: AlertsInboxErrorCodes.network,
      ),
    );

    await tester.pumpWidget(_app(cubit));

    expect(find.byKey(const Key('alerts_inbox_error')), findsOneWidget);
    expect(
      find.text('Could not reach the server. Check your connection and try again.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('alerts_inbox_retry')), findsOneWidget);
  });

  testWidgets('shows refresh error banner when list is visible', (tester) async {
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);
    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        errorCode: AlertsInboxErrorCodes.network,
        alerts: [
          const InboxAlert(
            id: 'a1',
            type: InboxAlertType.riskNews,
            severity: 'high',
            title: 'Risk headline',
            message: 'Risk body',
            createdAt: '2026-05-20T10:00:00.000Z',
          ),
        ],
      ),
    );

    await tester.pumpWidget(_app(cubit));

    expect(find.byKey(const Key('alerts_inbox_refresh_error')), findsOneWidget);
    expect(
      find.text('Could not refresh alerts. Pull down to try again.'),
      findsOneWidget,
    );
  });

  testWidgets('shows placeholder list items when loaded', (tester) async {
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);
    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        alerts: [
          const InboxAlert(
            id: 'a1',
            type: InboxAlertType.riskNews,
            severity: 'high',
            title: 'Risk headline',
            message: 'Risk body',
            createdAt: '2026-05-20T10:00:00.000Z',
          ),
        ],
      ),
    );

    await tester.pumpWidget(_app(cubit));

    expect(find.byKey(const Key('alerts_inbox_list')), findsOneWidget);
    expect(find.text('Risk headline'), findsOneWidget);
    expect(find.text('Risk body'), findsOneWidget);
  });

  testWidgets('tapping unread card triggers mark as read', (tester) async {
    final markUseCase = MockMarkAlertReadUseCase();
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: markUseCase,
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);

    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        alerts: [
          InboxAlert(
            id: 'unread-1',
            type: InboxAlertType.healthFactorBreach,
            severity: 'high',
            title: 'HF alert',
            message: 'HF dropped',
            createdAt: '2026-05-20T10:00:00.000Z',
            payload: const InboxAlertHealthFactorPayload(
              HealthFactorAlertPayload(
                healthFactor: '1.2',
                thresholdHf: '1.5',
              ),
            ),
          ),
        ],
      ),
    );

    when(() => markUseCase.execute('unread-1')).thenAnswer(
      (_) async => InboxAlert(
        id: 'unread-1',
        type: InboxAlertType.healthFactorBreach,
        severity: 'high',
        title: 'HF alert',
        message: 'HF dropped',
        createdAt: '2026-05-20T10:00:00.000Z',
        readAt: '2026-05-20T11:00:00.000Z',
        payload: const InboxAlertHealthFactorPayload(
          HealthFactorAlertPayload(
            healthFactor: '1.2',
            thresholdHf: '1.5',
          ),
        ),
      ),
    );

    await tester.pumpWidget(_app(cubit));
    await tester.tap(find.byKey(const Key('alerts_inbox_mark_read_unread-1')));
    await tester.pump();

    verify(() => markUseCase.execute('unread-1')).called(1);
  });

  testWidgets('long press copies unread alert without marking read', (tester) async {
    final markUseCase = MockMarkAlertReadUseCase();
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: markUseCase,
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);

    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        alerts: [
          InboxAlert(
            id: 'unread-copy',
            type: InboxAlertType.healthFactorBreach,
            severity: 'high',
            title: 'HF alert',
            message: 'HF dropped',
            createdAt: '2026-05-20T10:00:00.000Z',
            payload: const InboxAlertHealthFactorPayload(
              HealthFactorAlertPayload(
                healthFactor: '1.2',
                thresholdHf: '1.5',
              ),
            ),
          ),
        ],
      ),
    );

    await tester.pumpWidget(_app(cubit));
    await tester.longPress(find.byKey(const Key('alerts_inbox_tile_unread-copy')));
    await tester.pump();

    verifyNever(() => markUseCase.execute(any()));
  });

  testWidgets('short tap marks read and does not copy', (tester) async {
    final markUseCase = MockMarkAlertReadUseCase();
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: markUseCase,
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);

    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        alerts: [
          InboxAlert(
            id: 'unread-tap',
            type: InboxAlertType.riskNews,
            severity: 'high',
            title: 'Risk headline',
            message: 'Risk body',
            createdAt: '2026-05-20T10:00:00.000Z',
            payload: const InboxAlertRiskNewsPayload(
              RiskNewsPayload(targetScope: 'global'),
            ),
          ),
        ],
      ),
    );

    when(() => markUseCase.execute('unread-tap')).thenAnswer(
      (_) async => InboxAlert(
        id: 'unread-tap',
        type: InboxAlertType.riskNews,
        severity: 'high',
        title: 'Risk headline',
        message: 'Risk body',
        createdAt: '2026-05-20T10:00:00.000Z',
        readAt: '2026-05-20T11:00:00.000Z',
        payload: const InboxAlertRiskNewsPayload(
          RiskNewsPayload(targetScope: 'global'),
        ),
      ),
    );

    await tester.pumpWidget(_app(cubit));
    await tester.tap(find.byKey(const Key('alerts_inbox_mark_read_unread-tap')));
    await tester.pump();

    verify(() => markUseCase.execute('unread-tap')).called(1);
    expect(find.text('Alert copied to clipboard'), findsNothing);
  });

  testWidgets('shows snackbar when mark as read fails', (tester) async {
    final markUseCase = MockMarkAlertReadUseCase();
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: markUseCase,
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);
    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        alerts: [
          InboxAlert(
            id: 'a1',
            type: InboxAlertType.healthFactorBreach,
            severity: 'high',
            title: 'HF',
            message: 'Body',
            createdAt: '2026-05-20T10:00:00.000Z',
            payload: const InboxAlertHealthFactorPayload(
              HealthFactorAlertPayload(healthFactor: '1.0'),
            ),
          ),
        ],
      ),
    );

    await tester.pumpWidget(_app(cubit));
    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        markReadErrorCode: 'ALERT_READ_FAILED',
        alerts: [
          InboxAlert(
            id: 'a1',
            type: InboxAlertType.healthFactorBreach,
            severity: 'high',
            title: 'HF',
            message: 'Body',
            createdAt: '2026-05-20T10:00:00.000Z',
            payload: const InboxAlertHealthFactorPayload(
              HealthFactorAlertPayload(healthFactor: '1.0'),
            ),
          ),
        ],
      ),
    );
    await tester.pump();

    expect(find.text('Could not mark alert as read. Try again.'), findsOneWidget);
  });

  testWidgets('shows mark all as read when unreadCount is positive', (tester) async {
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);
    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        unreadCount: 2,
        alerts: [
          const InboxAlert(
            id: 'u1',
            type: InboxAlertType.riskNews,
            severity: 'high',
            title: 'Unread one',
            message: 'Body',
            createdAt: '2026-05-20T10:00:00.000Z',
          ),
        ],
      ),
    );

    await tester.pumpWidget(_app(cubit));

    expect(find.byKey(const Key('alerts_inbox_mark_all_read')), findsOneWidget);
    expect(find.text('Mark all as read'), findsOneWidget);
  });

  testWidgets('hides mark all as read when unreadCount is zero', (tester) async {
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);
    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        unreadCount: 0,
        alerts: [
          const InboxAlert(
            id: 'r1',
            type: InboxAlertType.riskNews,
            severity: 'high',
            title: 'Read one',
            message: 'Body',
            createdAt: '2026-05-20T10:00:00.000Z',
            readAt: '2026-05-20T09:00:00.000Z',
          ),
        ],
      ),
    );

    await tester.pumpWidget(_app(cubit));

    expect(find.byKey(const Key('alerts_inbox_mark_all_read')), findsNothing);
  });

  testWidgets('tapping mark all as read invokes bulk use case', (tester) async {
    final markAllUseCase = MockMarkAllAlertsReadUseCase();
    when(() => markAllUseCase.execute()).thenAnswer((_) async => 2);

    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: markAllUseCase,
    );
    addTearDown(cubit.close);
    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        unreadCount: 2,
        alerts: [
          const InboxAlert(
            id: 'u1',
            type: InboxAlertType.riskNews,
            severity: 'high',
            title: 'Unread',
            message: 'Body',
            createdAt: '2026-05-20T10:00:00.000Z',
          ),
        ],
      ),
    );

    await tester.pumpWidget(_app(cubit));
    await tester.tap(find.byKey(const Key('alerts_inbox_mark_all_read')));
    await tester.pumpAndSettle();

    verify(() => markAllUseCase.execute()).called(1);
  });

  testWidgets('mark all as read button is disabled while marking all', (tester) async {
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);
    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        unreadCount: 1,
        isMarkingAllRead: true,
        alerts: [
          const InboxAlert(
            id: 'u1',
            type: InboxAlertType.riskNews,
            severity: 'high',
            title: 'Unread',
            message: 'Body',
            createdAt: '2026-05-20T10:00:00.000Z',
          ),
        ],
      ),
    );

    await tester.pumpWidget(_app(cubit));

    final button = tester.widget<TextButton>(
      find.byKey(const Key('alerts_inbox_mark_all_read')),
    );
    expect(button.onPressed, isNull);
    expect(find.text('Marking as read…'), findsOneWidget);
  });

  testWidgets('shows snackbar when mark all as read fails and clears error', (tester) async {
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);
    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        unreadCount: 2,
        alerts: [
          const InboxAlert(
            id: 'u1',
            type: InboxAlertType.riskNews,
            severity: 'high',
            title: 'Unread',
            message: 'Body',
            createdAt: '2026-05-20T10:00:00.000Z',
          ),
        ],
      ),
    );

    await tester.pumpWidget(_app(cubit));
    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        unreadCount: 2,
        markAllReadErrorCode: 'ALERT_READ_ALL_FAILED',
        alerts: [
          const InboxAlert(
            id: 'u1',
            type: InboxAlertType.riskNews,
            severity: 'high',
            title: 'Unread',
            message: 'Body',
            createdAt: '2026-05-20T10:00:00.000Z',
          ),
        ],
      ),
    );
    await tester.pump();

    expect(
      find.text('Could not mark all alerts as read. Try again.'),
      findsOneWidget,
    );
    expect(cubit.state.markAllReadErrorCode, isNull);
  });

  testWidgets('shell badge hides when cubit unreadCount becomes zero', (tester) async {
    final cubit = AlertsInboxCubit(
      getAlertsUseCase: MockGetAlertsUseCase(),
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    addTearDown(cubit.close);
    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        unreadCount: 3,
        alerts: [
          const InboxAlert(
            id: 'u1',
            type: InboxAlertType.riskNews,
            severity: 'high',
            title: 'Unread',
            message: 'Body',
            createdAt: '2026-05-20T10:00:00.000Z',
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: BlocProvider<AlertsInboxCubit>.value(
          value: cubit,
          child: const Scaffold(
            body: Column(
              children: [
                ShellAlertsNavIcon(),
                Expanded(child: AlertsInboxPage()),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('shell_alerts_unread_badge')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    cubit.emit(
      AlertsInboxState(
        status: AlertsInboxStatus.loaded,
        unreadCount: 0,
        alerts: [
          const InboxAlert(
            id: 'u1',
            type: InboxAlertType.riskNews,
            severity: 'high',
            title: 'Unread',
            message: 'Body',
            createdAt: '2026-05-20T10:00:00.000Z',
            readAt: '2026-05-20T11:00:00.000Z',
          ),
        ],
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('shell_alerts_unread_badge')), findsNothing);
    expect(find.byKey(const Key('alerts_inbox_mark_all_read')), findsNothing);
  });
}

Widget _app(AlertsInboxCubit cubit) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: BlocProvider<AlertsInboxCubit>.value(
      value: cubit,
      child: const Scaffold(body: AlertsInboxPage()),
    ),
  );
}
