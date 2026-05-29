import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';

enum AlertRulesStatus {
  initial,
  loading,
  loaded,
  saving,
  success,
  failure,
}

class AlertRulesState {
  const AlertRulesState({
    this.status = AlertRulesStatus.initial,
    this.globalRule,
    this.thresholdInput = '',
    this.enabled = true,
    this.errorMessage,
    this.successMessage,
  });

  final AlertRulesStatus status;
  final AlertRule? globalRule;
  final String thresholdInput;
  final bool enabled;
  final String? errorMessage;
  final String? successMessage;

  AlertRulesState copyWith({
    AlertRulesStatus? status,
    AlertRule? globalRule,
    String? thresholdInput,
    bool? enabled,
    String? errorMessage,
    String? successMessage,
    bool clearGlobalRule = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AlertRulesState(
      status: status ?? this.status,
      globalRule: clearGlobalRule ? null : (globalRule ?? this.globalRule),
      thresholdInput: thresholdInput ?? this.thresholdInput,
      enabled: enabled ?? this.enabled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
