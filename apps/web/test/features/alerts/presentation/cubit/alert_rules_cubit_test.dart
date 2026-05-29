import 'package:bloc_test/bloc_test.dart';
import 'package:cryprice_frontend/core/network/api_error.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alert_rules_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/upsert_global_hf_alert_rule_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_cubit.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAlertRulesUseCase extends Mock implements GetAlertRulesUseCase {}

class MockUpsertGlobalHfAlertRuleUseCase extends Mock implements UpsertGlobalHfAlertRuleUseCase {}

AlertRulesCubit _buildCubit({
  required MockGetAlertRulesUseCase getAlertRulesUseCase,
  required MockUpsertGlobalHfAlertRuleUseCase upsertUseCase,
}) {
  return AlertRulesCubit(
    getAlertRulesUseCase: getAlertRulesUseCase,
    upsertGlobalHfAlertRuleUseCase: upsertUseCase,
  );
}

void main() {
  late MockGetAlertRulesUseCase getAlertRulesUseCase;
  late MockUpsertGlobalHfAlertRuleUseCase upsertUseCase;

  setUp(() {
    getAlertRulesUseCase = MockGetAlertRulesUseCase();
    upsertUseCase = MockUpsertGlobalHfAlertRuleUseCase();
  });

  blocTest<AlertRulesCubit, AlertRulesState>(
    'load with existing global rule uses rule threshold and enabled',
    build: () {
      when(() => getAlertRulesUseCase.execute()).thenAnswer(
        (_) async => [_globalRule(thresholdHf: '1.25', enabled: false)],
      );
      return _buildCubit(
        getAlertRulesUseCase: getAlertRulesUseCase,
        upsertUseCase: upsertUseCase,
      );
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<AlertRulesState>().having((s) => s.status, 'status', AlertRulesStatus.loading),
      isA<AlertRulesState>()
          .having((s) => s.status, 'status', AlertRulesStatus.loaded)
          .having((s) => s.globalRule?.id, 'globalRule.id', 'rule-1')
          .having((s) => s.thresholdInput, 'thresholdInput', '1.25')
          .having((s) => s.enabled, 'enabled', isFalse),
    ],
    verify: (_) {
      verify(() => getAlertRulesUseCase.execute()).called(1);
    },
  );

  blocTest<AlertRulesCubit, AlertRulesState>(
    'load with no rule uses fallback threshold',
    build: () {
      when(() => getAlertRulesUseCase.execute()).thenAnswer((_) async => const <AlertRule>[]);
      return _buildCubit(
        getAlertRulesUseCase: getAlertRulesUseCase,
        upsertUseCase: upsertUseCase,
      );
    },
    act: (cubit) => cubit.load(fallbackThresholdHf: 1.5),
    expect: () => [
      isA<AlertRulesState>().having((s) => s.status, 'status', AlertRulesStatus.loading),
      isA<AlertRulesState>()
          .having((s) => s.status, 'status', AlertRulesStatus.loaded)
          .having((s) => s.globalRule, 'globalRule', isNull)
          .having((s) => s.thresholdInput, 'thresholdInput', '1.5')
          .having((s) => s.enabled, 'enabled', isTrue),
    ],
  );

  blocTest<AlertRulesCubit, AlertRulesState>(
    'load with no rule and no fallback uses default threshold 2.0',
    build: () {
      when(() => getAlertRulesUseCase.execute()).thenAnswer((_) async => const <AlertRule>[]);
      return _buildCubit(
        getAlertRulesUseCase: getAlertRulesUseCase,
        upsertUseCase: upsertUseCase,
      );
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<AlertRulesState>().having((s) => s.status, 'status', AlertRulesStatus.loading),
      isA<AlertRulesState>()
          .having((s) => s.status, 'status', AlertRulesStatus.loaded)
          .having((s) => s.thresholdInput, 'thresholdInput', '2'),
    ],
  );

  blocTest<AlertRulesCubit, AlertRulesState>(
    'invalid threshold blocks save',
    build: () {
      when(() => getAlertRulesUseCase.execute()).thenAnswer((_) async => const <AlertRule>[]);
      return _buildCubit(
        getAlertRulesUseCase: getAlertRulesUseCase,
        upsertUseCase: upsertUseCase,
      );
    },
    act: (cubit) async {
      await cubit.load();
      cubit.setThresholdInput('0.001');
      await cubit.save();
    },
    expect: () => [
      isA<AlertRulesState>().having((s) => s.status, 'status', AlertRulesStatus.loading),
      isA<AlertRulesState>().having((s) => s.status, 'status', AlertRulesStatus.loaded),
      isA<AlertRulesState>().having((s) => s.thresholdInput, 'thresholdInput', '0.001'),
      isA<AlertRulesState>()
          .having((s) => s.status, 'status', AlertRulesStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', kAlertRulesThresholdRangeErrorCode),
    ],
    verify: (_) {
      verifyNever(() => upsertUseCase.execute(thresholdHf: any(named: 'thresholdHf'), enabled: any(named: 'enabled')));
    },
  );

  blocTest<AlertRulesCubit, AlertRulesState>(
    'save calls upsert with parsed threshold and enabled flag',
    build: () {
      when(() => getAlertRulesUseCase.execute()).thenAnswer((_) async => const <AlertRule>[]);
      when(
        () => upsertUseCase.execute(
          thresholdHf: any(named: 'thresholdHf'),
          enabled: any(named: 'enabled'),
        ),
      ).thenAnswer(
        (_) async => _globalRule(thresholdHf: '1.8', enabled: true),
      );
      return _buildCubit(
        getAlertRulesUseCase: getAlertRulesUseCase,
        upsertUseCase: upsertUseCase,
      );
    },
    act: (cubit) async {
      await cubit.load();
      cubit.setThresholdInput('1.8');
      await cubit.save();
    },
    expect: () => [
      isA<AlertRulesState>().having((s) => s.status, 'status', AlertRulesStatus.loading),
      isA<AlertRulesState>().having((s) => s.status, 'status', AlertRulesStatus.loaded),
      isA<AlertRulesState>().having((s) => s.thresholdInput, 'thresholdInput', '1.8'),
      isA<AlertRulesState>().having((s) => s.status, 'status', AlertRulesStatus.saving),
      isA<AlertRulesState>()
          .having((s) => s.status, 'status', AlertRulesStatus.success)
          .having((s) => s.globalRule?.thresholdHf, 'globalRule.thresholdHf', '1.8')
          .having((s) => s.successMessage, 'successMessage', isNull),
    ],
    verify: (_) {
      verify(
        () => upsertUseCase.execute(thresholdHf: 1.8, enabled: true),
      ).called(1);
    },
  );

  blocTest<AlertRulesCubit, AlertRulesState>(
    'save maps repository errors to failure state',
    build: () {
      when(() => getAlertRulesUseCase.execute()).thenAnswer((_) async => const <AlertRule>[]);
      when(
        () => upsertUseCase.execute(
          thresholdHf: any(named: 'thresholdHf'),
          enabled: any(named: 'enabled'),
        ),
      ).thenAnswer((_) async {
        throw const ApiError(
          message: 'Alert rules unavailable',
          code: 'ALERT_RULES_UNAVAILABLE',
          statusCode: 503,
        );
      });
      return _buildCubit(
        getAlertRulesUseCase: getAlertRulesUseCase,
        upsertUseCase: upsertUseCase,
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.save();
    },
    expect: () => [
      isA<AlertRulesState>().having((s) => s.status, 'status', AlertRulesStatus.loading),
      isA<AlertRulesState>().having((s) => s.status, 'status', AlertRulesStatus.loaded),
      isA<AlertRulesState>().having((s) => s.status, 'status', AlertRulesStatus.saving),
      isA<AlertRulesState>()
          .having((s) => s.status, 'status', AlertRulesStatus.failure)
          .having((s) => s.errorMessage, 'errorMessage', 'Alert rules unavailable'),
    ],
  );
}

AlertRule _globalRule({
  String id = 'rule-1',
  String thresholdHf = '1.25',
  bool enabled = true,
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
    createdAt: '2026-05-19T10:00:00.000Z',
    updatedAt: '2026-05-19T10:00:00.000Z',
  );
}
