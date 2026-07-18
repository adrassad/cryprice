import 'package:cryprice_frontend/features/alerts/data/models/create_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/data/models/update_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';
import 'package:cryprice_frontend/features/alerts/domain/repositories/alert_rules_repository.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/upsert_global_hf_alert_rule_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertRulesRepository extends Mock implements AlertRulesRepository {}

void main() {
  late MockAlertRulesRepository repository;
  late UpsertGlobalHfAlertRuleUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const CreateAlertRuleRequest(
        type: 'health_factor_threshold',
        protocol: 'aave',
        thresholdHf: '1.0',
        direction: 'below',
        enabled: true,
        cooldownMinutes: 30,
      ),
    );
    registerFallbackValue(
      const UpdateAlertRuleRequest(thresholdHf: '1.0', enabled: true),
    );
  });

  setUp(() {
    repository = MockAlertRulesRepository();
    useCase = UpsertGlobalHfAlertRuleUseCase(repository);
  });

  test('creates global rule when none exists', () async {
    when(() => repository.getAlertRules()).thenAnswer((_) async => const <AlertRule>[]);
    when(() => repository.createAlertRule(any())).thenAnswer(
      (_) async => _globalRule(id: 'rule-new', thresholdHf: '1.5'),
    );

    final result = await useCase.execute(thresholdHf: 1.5, enabled: true);

    expect(result.id, 'rule-new');
    verify(() => repository.getAlertRules()).called(1);
    final captured = verify(() => repository.createAlertRule(captureAny())).captured.single
        as CreateAlertRuleRequest;
    expect(captured.type, 'health_factor_threshold');
    expect(captured.protocol, isNull);
    expect(captured.thresholdHf, '1.5');
    expect(captured.direction, 'below');
    expect(captured.enabled, isTrue);
    expect(captured.cooldownMinutes, 30);
    expect(captured.walletId, isNull);
    expect(captured.networkId, isNull);
    verifyNever(() => repository.updateAlertRule(any(), any()));
  });

  test('patches existing global rule when one exists', () async {
    when(() => repository.getAlertRules()).thenAnswer(
      (_) async => [_globalRule(id: 'rule-existing', thresholdHf: '1.25')],
    );
    when(() => repository.updateAlertRule(any(), any())).thenAnswer(
      (_) async => _globalRule(id: 'rule-existing', thresholdHf: '1.8', enabled: false),
    );

    final result = await useCase.execute(thresholdHf: 1.8, enabled: false);

    expect(result.thresholdHf, '1.8');
    expect(result.enabled, isFalse);
    verifyNever(() => repository.createAlertRule(any()));
    final captured = verify(() => repository.updateAlertRule(captureAny(), captureAny())).captured;
    expect(captured[0], 'rule-existing');
    final request = captured[1] as UpdateAlertRuleRequest;
    expect(request.thresholdHf, '1.8');
    expect(request.enabled, isFalse);
    expect(request.cooldownMinutes, isNull);
  });

  test('patches newest global rule when multiple exist', () async {
    when(() => repository.getAlertRules()).thenAnswer(
      (_) async => [
        _globalRule(
          id: 'rule-old',
          updatedAt: '2026-05-18T10:00:00.000Z',
          createdAt: '2026-05-17T10:00:00.000Z',
        ),
        _globalRule(
          id: 'rule-newest',
          updatedAt: '2026-05-20T10:00:00.000Z',
          createdAt: '2026-05-19T10:00:00.000Z',
        ),
        _globalRule(
          id: 'rule-middle',
          updatedAt: '2026-05-19T10:00:00.000Z',
          createdAt: '2026-05-18T10:00:00.000Z',
        ),
      ],
    );
    when(() => repository.updateAlertRule(any(), any())).thenAnswer(
      (_) async => _globalRule(id: 'rule-newest', thresholdHf: '2'),
    );

    await useCase.execute(thresholdHf: 2, enabled: true);

    final captured = verify(() => repository.updateAlertRule(captureAny(), captureAny())).captured;
    expect(captured[0], 'rule-newest');
    final request = captured[1] as UpdateAlertRuleRequest;
    expect(request.thresholdHf, '2');
    expect(request.enabled, isTrue);
    verifyNever(() => repository.createAlertRule(any()));
  });

  test('ignores scoped rules when selecting global rule', () async {
    when(() => repository.getAlertRules()).thenAnswer(
      (_) async => [
        _globalRule(id: 'rule-global'),
        _scopedRule(id: 'rule-scoped'),
      ],
    );
    when(() => repository.updateAlertRule(any(), any())).thenAnswer(
      (_) async => _globalRule(id: 'rule-global', thresholdHf: '1.75'),
    );

    await useCase.execute(thresholdHf: 1.75, enabled: true);

    verify(() => repository.updateAlertRule('rule-global', any())).called(1);
    verifyNever(() => repository.createAlertRule(any()));
  });

  group('serializeThresholdHf', () {
    test('serializes whole and fractional values without trailing zeros', () {
      expect(serializeThresholdHf(1.25), '1.25');
      expect(serializeThresholdHf(1.5), '1.5');
      expect(serializeThresholdHf(2), '2');
      expect(serializeThresholdHf(9999.99), '9999.99');
    });
  });
}

AlertRule _globalRule({
  required String id,
  String thresholdHf = '1.25',
  bool enabled = true,
  String updatedAt = '2026-05-19T10:00:00.000Z',
  String createdAt = '2026-05-19T10:00:00.000Z',
}) {
  return AlertRule(
    id: id,
    userId: 'user-1',
    type: 'health_factor_threshold',
    protocol: 'aave',
    walletId: null,
    networkId: null,
    thresholdHf: thresholdHf,
    direction: 'below',
    enabled: enabled,
    cooldownMinutes: 30,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

AlertRule _scopedRule({required String id}) {
  return AlertRule(
    id: id,
    userId: 'user-1',
    type: 'health_factor_threshold',
    protocol: 'aave',
    walletId: 'wallet-1',
    networkId: 'network-1',
    thresholdHf: '1.25',
    direction: 'below',
    enabled: true,
    cooldownMinutes: 30,
    createdAt: '2026-05-19T10:00:00.000Z',
    updatedAt: '2026-05-19T10:00:00.000Z',
  );
}
