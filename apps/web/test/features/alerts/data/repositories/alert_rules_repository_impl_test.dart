import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/alerts/data/datasources/alert_rules_remote_datasource.dart';
import 'package:cryprice_frontend/features/alerts/data/models/create_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/data/models/update_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/data/repositories/alert_rules_repository_impl.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertRulesRemoteDataSource extends Mock implements AlertRulesRemoteDataSource {}

void main() {
  late MockAlertRulesRemoteDataSource remote;
  late AlertRulesRepositoryImpl repository;

  setUp(() {
    remote = MockAlertRulesRemoteDataSource();
    repository = AlertRulesRepositoryImpl(remote: remote);
  });

  test('getAlertRules delegates to remote data source', () async {
    final rules = <AlertRule>[_globalRule(id: 'rule-1')];
    when(() => remote.getAlertRules()).thenAnswer((_) async => rules);

    final result = await repository.getAlertRules();

    expect(result, same(rules));
    verify(() => remote.getAlertRules()).called(1);
  });

  test('createAlertRule delegates to remote data source', () async {
    const request = CreateAlertRuleRequest(
      type: 'health_factor_threshold',
      protocol: 'aave',
      thresholdHf: '1.5',
      direction: 'below',
      enabled: true,
      cooldownMinutes: 30,
    );
    final rule = _globalRule(id: 'rule-new');
    when(() => remote.createAlertRule(request)).thenAnswer((_) async => rule);

    final result = await repository.createAlertRule(request);

    expect(result, same(rule));
    verify(() => remote.createAlertRule(request)).called(1);
  });

  test('updateAlertRule delegates to remote data source', () async {
    const request = UpdateAlertRuleRequest(thresholdHf: '1.8', enabled: false);
    final rule = _globalRule(id: 'rule-1', thresholdHf: '1.8', enabled: false);
    when(() => remote.updateAlertRule('rule-1', request)).thenAnswer((_) async => rule);

    final result = await repository.updateAlertRule('rule-1', request);

    expect(result, same(rule));
    verify(() => remote.updateAlertRule('rule-1', request)).called(1);
  });

  test('getAlertRules propagates remote errors', () async {
    const error = ApiError(
      message: 'Alert rules unavailable',
      code: 'ALERT_RULES_UNAVAILABLE',
      statusCode: 503,
    );
    when(() => remote.getAlertRules()).thenAnswer((_) async {
      throw error;
    });

    expect(
      repository.getAlertRules(),
      throwsA(
        isA<ApiError>()
            .having((e) => e.statusCode, 'statusCode', 503)
            .having((e) => e.code, 'code', 'ALERT_RULES_UNAVAILABLE'),
      ),
    );
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
