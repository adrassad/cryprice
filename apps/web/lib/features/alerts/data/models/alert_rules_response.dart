import 'package:cryprice_frontend/features/alerts/data/models/alert_rule_model.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';

class AlertRulesResponse {
  const AlertRulesResponse({required this.rules});

  final List<AlertRule> rules;

  factory AlertRulesResponse.fromJson(Map<String, Object?> json) {
    final raw = json['rules'];
    if (raw is! List) {
      return const AlertRulesResponse(rules: <AlertRule>[]);
    }
    return AlertRulesResponse(
      rules: raw
          .whereType<Map>()
          .map((item) => AlertRuleModel.fromJson(item.cast<String, Object?>()).toEntity())
          .toList(growable: false),
    );
  }
}

class AlertRuleResponse {
  const AlertRuleResponse({required this.rule});

  final AlertRule rule;

  factory AlertRuleResponse.fromJson(Map<String, Object?> json) {
    final raw = json['rule'];
    if (raw is Map<String, Object?>) {
      return AlertRuleResponse(rule: AlertRuleModel.fromJson(raw).toEntity());
    }
    if (raw is Map) {
      return AlertRuleResponse(rule: AlertRuleModel.fromJson(raw.cast<String, Object?>()).toEntity());
    }
    return AlertRuleResponse(
      rule: AlertRuleModel.fromJson(const <String, Object?>{}).toEntity(),
    );
  }
}
