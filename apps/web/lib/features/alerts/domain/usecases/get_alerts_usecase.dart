import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/repositories/alerts_inbox_repository.dart';

class GetAlertsUseCase {
  GetAlertsUseCase(this._repository);

  final AlertsInboxRepository _repository;

  Future<List<InboxAlert>> execute() => _repository.getAlerts();
}
