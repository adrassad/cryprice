import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';
import 'package:cryprice_frontend/features/alerts/domain/repositories/alert_rules_repository.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alert_rules_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertRulesRepository extends Mock implements AlertRulesRepository {}

void main() {
  late MockAlertRulesRepository repository;
  late GetAlertRulesUseCase useCase;

  setUp(() {
    repository = MockAlertRulesRepository();
    useCase = GetAlertRulesUseCase(repository);
  });

  test('execute delegates to repository', () async {
    final rules = <AlertRule>[
      const AlertRule(
        id: 'rule-1',
        userId: 'user-1',
        type: 'health_factor_threshold',
        protocol: 'aave',
        thresholdHf: '1.25',
        direction: 'below',
        enabled: true,
        cooldownMinutes: 30,
        createdAt: '2026-05-19T10:00:00.000Z',
        updatedAt: '2026-05-19T10:00:00.000Z',
      ),
    ];
    when(() => repository.getAlertRules()).thenAnswer((_) async => rules);

    final result = await useCase.execute();

    expect(result, same(rules));
    verify(() => repository.getAlertRules()).called(1);
  });
}
