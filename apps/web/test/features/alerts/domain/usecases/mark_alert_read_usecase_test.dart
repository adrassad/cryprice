import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/domain/repositories/alerts_inbox_repository.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_alert_read_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertsInboxRepository extends Mock implements AlertsInboxRepository {}

void main() {
  late MockAlertsInboxRepository repository;
  late MarkAlertReadUseCase useCase;

  setUp(() {
    repository = MockAlertsInboxRepository();
    useCase = MarkAlertReadUseCase(repository);
  });

  test('execute delegates to repository', () async {
    const alert = InboxAlert(
      id: 'alert-1',
      type: InboxAlertType.riskNews,
      severity: 'high',
      title: 'Risk',
      message: 'Body',
      createdAt: '2026-05-20T08:00:00.000Z',
      readAt: '2026-05-20T09:00:00.000Z',
    );
    when(() => repository.markAlertRead('alert-1')).thenAnswer((_) async => alert);

    final result = await useCase.execute('alert-1');

    expect(result, same(alert));
    verify(() => repository.markAlertRead('alert-1')).called(1);
  });
}
