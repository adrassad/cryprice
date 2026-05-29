import 'package:cryprice_frontend/features/alerts/domain/entities/alert_rule.dart';
import 'package:cryprice_frontend/features/alerts/domain/repositories/alert_rules_repository.dart';

class GetAlertRulesUseCase {
  GetAlertRulesUseCase(this._repository);

  final AlertRulesRepository _repository;

  Future<List<AlertRule>> execute() => _repository.getAlertRules();
}
