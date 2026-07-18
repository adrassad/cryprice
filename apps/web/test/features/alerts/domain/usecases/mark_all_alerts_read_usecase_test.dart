import 'package:cryprice_frontend/features/alerts/domain/repositories/alerts_inbox_repository.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/mark_all_alerts_read_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertsInboxRepository extends Mock implements AlertsInboxRepository {}

void main() {
  late MockAlertsInboxRepository repository;
  late MarkAllAlertsReadUseCase useCase;

  setUp(() {
    repository = MockAlertsInboxRepository();
    useCase = MarkAllAlertsReadUseCase(repository);
  });

  test('execute delegates to repository', () async {
    when(() => repository.markAllAsRead()).thenAnswer((_) async => 12);

    final result = await useCase.execute();

    expect(result, 12);
    verify(() => repository.markAllAsRead()).called(1);
  });
}
