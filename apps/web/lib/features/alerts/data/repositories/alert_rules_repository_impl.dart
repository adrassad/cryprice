import 'package:cryprice_frontend/features/alerts/data/datasources/alert_rules_remote_datasource.dart';
import 'package:cryprice_frontend/features/alerts/data/models/create_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/data/models/update_alert_rule_request.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';
import 'package:cryprice_frontend/features/alerts/domain/repositories/alert_rules_repository.dart';

class AlertRulesRepositoryImpl implements AlertRulesRepository {
  AlertRulesRepositoryImpl({required AlertRulesRemoteDataSource remote}) : _remote = remote;

  final AlertRulesRemoteDataSource _remote;

  @override
  Future<List<AlertRule>> getAlertRules() => _remote.getAlertRules();

  @override
  Future<AlertRule> createAlertRule(CreateAlertRuleRequest request) =>
      _remote.createAlertRule(request);

  @override
  Future<AlertRule> updateAlertRule(String id, UpdateAlertRuleRequest request) =>
      _remote.updateAlertRule(id, request);
}
