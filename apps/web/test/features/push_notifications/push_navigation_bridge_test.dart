import 'package:cryprice_frontend/core/navigation/app_section.dart';
import 'package:cryprice_frontend/core/navigation/push_navigation_bridge.dart';
import 'package:cryprice_frontend/core/shell/cubit/shell_navigation_cubit.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_alert_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_all_alerts_read_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alerts_inbox_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAlertsUseCase extends Mock implements GetAlertsUseCase {}

class MockMarkAlertReadUseCase extends Mock implements MarkAlertReadUseCase {}

class MockMarkAllAlertsReadUseCase extends Mock implements MarkAllAlertsReadUseCase {}

void main() {
  late ShellNavigationCubit shellNavigationCubit;
  late AlertsInboxCubit alertsInboxCubit;
  late MockGetAlertsUseCase getAlertsUseCase;
  late ShellPushNavigationBridge bridge;

  setUp(() {
    shellNavigationCubit = ShellNavigationCubit();
    getAlertsUseCase = MockGetAlertsUseCase();
    when(() => getAlertsUseCase.execute()).thenAnswer((_) async => []);
    alertsInboxCubit = AlertsInboxCubit(
      getAlertsUseCase: getAlertsUseCase,
      markAlertReadUseCase: MockMarkAlertReadUseCase(),
      markAllAlertsReadUseCase: MockMarkAllAlertsReadUseCase(),
    );
    bridge = ShellPushNavigationBridge(shellNavigationCubit, alertsInboxCubit);
  });

  tearDown(() async {
    await alertsInboxCubit.close();
    await shellNavigationCubit.close();
  });

  test('openAlerts selects alerts section and focuses alert', () async {
    bridge.openAlerts(alertId: 'alert-99');

    expect(shellNavigationCubit.state.selectedSection, AppSection.alerts);
    await Future<void>.delayed(Duration.zero);
    expect(alertsInboxCubit.state.pendingFocusAlertId, 'alert-99');
    expect(alertsInboxCubit.state.highlightedAlertId, 'alert-99');
  });

  test('openAlerts focuses alert when alerts section is already selected', () async {
    shellNavigationCubit.selectSection(AppSection.alerts);

    bridge.openAlerts(alertId: 'alert-7');
    await Future<void>.delayed(Duration.zero);

    expect(shellNavigationCubit.state.selectedSection, AppSection.alerts);
    expect(alertsInboxCubit.state.pendingFocusAlertId, 'alert-7');
  });
}
