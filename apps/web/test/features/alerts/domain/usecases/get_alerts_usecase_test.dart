import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/domain/repositories/alerts_inbox_repository.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertsInboxRepository extends Mock implements AlertsInboxRepository {}

void main() {
  late MockAlertsInboxRepository repository;
  late GetAlertsUseCase useCase;

  setUp(() {
    repository = MockAlertsInboxRepository();
    useCase = GetAlertsUseCase(repository);
  });

  test('execute delegates to repository', () async {
    final alerts = <InboxAlert>[
      const InboxAlert(
        id: 'alert-1',
        type: InboxAlertType.riskNews,
        severity: 'high',
        title: 'Risk',
        message: 'Body',
        createdAt: '2026-05-20T08:00:00.000Z',
      ),
    ];
    when(() => repository.getAlerts()).thenAnswer((_) async => alerts);

    final result = await useCase.execute();

    expect(result, same(alerts));
    verify(() => repository.getAlerts()).called(1);
  });
}
