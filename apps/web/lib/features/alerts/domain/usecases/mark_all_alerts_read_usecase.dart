import 'package:cryprice_frontend/features/alerts/domain/repositories/alerts_inbox_repository.dart';

class MarkAllAlertsReadUseCase {
  MarkAllAlertsReadUseCase(this._repository);

  final AlertsInboxRepository _repository;

  Future<int> execute() => _repository.markAllAsRead();
}
