import 'package:cryprice_frontend/features/alerts/data/models/create_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/data/models/update_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';
import 'package:cryprice_frontend/features/alerts/domain/repositories/alert_rules_repository.dart';

const String kHealthFactorThresholdType = 'health_factor_threshold';
const int kDefaultGlobalHfCooldownMinutes = 30;

/// Creates or updates the user's global Health Factor alert rule.
class UpsertGlobalHfAlertRuleUseCase {
  UpsertGlobalHfAlertRuleUseCase(this._repository);

  final AlertRulesRepository _repository;

  Future<AlertRule> execute({
    required double thresholdHf,
    required bool enabled,
  }) async {
    final rules = await _repository.getAlertRules();
    final existing = _selectNewestGlobalHealthFactorRule(rules);
    final thresholdHfText = serializeThresholdHf(thresholdHf);

    if (existing == null) {
      return _repository.createAlertRule(
        CreateAlertRuleRequest(
          type: kHealthFactorThresholdType,
          protocol: 'aave',
          thresholdHf: thresholdHfText,
          direction: 'below',
          enabled: enabled,
          cooldownMinutes: kDefaultGlobalHfCooldownMinutes,
          walletId: null,
          networkId: null,
        ),
      );
    }

    return _repository.updateAlertRule(
      existing.id,
      UpdateAlertRuleRequest(
        thresholdHf: thresholdHfText,
        enabled: enabled,
      ),
    );
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
}

/// Serializes a UI threshold value to the decimal string expected by the API.
String serializeThresholdHf(double thresholdHf) {
  var text = thresholdHf.toStringAsFixed(2);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return text;
}
