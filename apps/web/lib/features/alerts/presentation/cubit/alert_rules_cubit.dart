import 'package:cryprice_frontend/core/network/api_error_parser.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/get_alert_rules_usecase.dart';
import 'package:cryprice_frontend/features/alerts/domain/usecases/upsert_global_hf_alert_rule_usecase.dart';
import 'package:cryprice_frontend/features/alerts/presentation/cubit/alert_rules_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const double kDefaultGlobalHfThreshold = 2.0;
const double kMinHfThreshold = 0.01;
const double kMaxHfThreshold = 9999.99;

/// Emitted in [AlertRulesState.errorMessage] for client-side threshold validation.
const String kAlertRulesThresholdRangeErrorCode = 'THRESHOLD_RANGE';

class AlertRulesCubit extends Cubit<AlertRulesState> {
  AlertRulesCubit({
    required GetAlertRulesUseCase getAlertRulesUseCase,
    required UpsertGlobalHfAlertRuleUseCase upsertGlobalHfAlertRuleUseCase,
  })  : _getAlertRulesUseCase = getAlertRulesUseCase,
        _upsertGlobalHfAlertRuleUseCase = upsertGlobalHfAlertRuleUseCase,
        super(const AlertRulesState());

  final GetAlertRulesUseCase _getAlertRulesUseCase;
  final UpsertGlobalHfAlertRuleUseCase _upsertGlobalHfAlertRuleUseCase;

  Future<void> load({double? fallbackThresholdHf}) async {
    emit(
      state.copyWith(
        status: AlertRulesStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final rules = await _getAlertRulesUseCase.execute();
      final globalRule = _selectNewestGlobalHealthFactorRule(rules);
      if (globalRule != null) {
        emit(
          state.copyWith(
            status: AlertRulesStatus.loaded,
            globalRule: globalRule,
            thresholdInput: globalRule.thresholdHf,
            enabled: globalRule.enabled,
            clearError: true,
            clearSuccess: true,
          ),
        );
        return;
      }
      final threshold = fallbackThresholdHf ?? kDefaultGlobalHfThreshold;
      emit(
        state.copyWith(
          status: AlertRulesStatus.loaded,
          clearGlobalRule: true,
          thresholdInput: serializeThresholdHf(threshold),
          enabled: true,
          clearError: true,
          clearSuccess: true,
        ),
      );
    } on Object catch (e) {
      _emitFailure(e);
    }
  }

  void setThresholdInput(String value) {
    emit(state.copyWith(thresholdInput: value));
  }

  void setEnabled(bool value) {
    emit(state.copyWith(enabled: value));
  }

  Future<void> save() async {
    final parsedThreshold = double.tryParse(state.thresholdInput.trim());
    if (parsedThreshold == null ||
        parsedThreshold < kMinHfThreshold ||
        parsedThreshold > kMaxHfThreshold) {
      emit(
        state.copyWith(
          status: AlertRulesStatus.failure,
          errorMessage: kAlertRulesThresholdRangeErrorCode,
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AlertRulesStatus.saving,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final rule = await _upsertGlobalHfAlertRuleUseCase.execute(
        thresholdHf: parsedThreshold,
        enabled: state.enabled,
      );
      emit(
        state.copyWith(
          status: AlertRulesStatus.success,
          globalRule: rule,
          thresholdInput: rule.thresholdHf,
          enabled: rule.enabled,
          clearSuccess: true,
        ),
      );
    } on Object catch (e) {
      _emitFailure(e);
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  AlertRule? _selectNewestGlobalHealthFactorRule(List<AlertRule> rules) {
    final globalRules = rules
        .where(
          (rule) => rule.isGlobalRule && rule.type == kHealthFactorThresholdType,
        )
        .toList(growable: false);
    if (globalRules.isEmpty) {
      return null;
    }
    globalRules.sort((a, b) => _ruleTimestamp(b).compareTo(_ruleTimestamp(a)));
    return globalRules.first;
  }

  DateTime _ruleTimestamp(AlertRule rule) {
    return DateTime.tryParse(rule.updatedAt) ??
        DateTime.tryParse(rule.createdAt) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _emitFailure(Object e) {
    final apiError = parseApiError(e);
    emit(
      state.copyWith(
        status: AlertRulesStatus.failure,
        errorMessage: apiError.message,
        clearSuccess: true,
      ),
    );
  }
}
