import 'package:cryprice_frontend/features/alerts/data/models/create_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/data/models/update_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';

abstract class AlertRulesRepository {
  Future<List<AlertRule>> getAlertRules();

  Future<AlertRule> createAlertRule(CreateAlertRuleRequest request);

  Future<AlertRule> updateAlertRule(String id, UpdateAlertRuleRequest request);
}
