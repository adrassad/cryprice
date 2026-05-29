import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/repositories/alerts_inbox_repository.dart';

class MarkAlertReadUseCase {
  MarkAlertReadUseCase(this._repository);

  final AlertsInboxRepository _repository;

  Future<InboxAlert> execute(String id) => _repository.markAlertRead(id);
}
