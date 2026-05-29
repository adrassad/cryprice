import 'package:cryprice_frontend/features/alerts/data/datasources/alerts_inbox_remote_datasource.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/repositories/alerts_inbox_repository.dart';

class AlertsInboxRepositoryImpl implements AlertsInboxRepository {
  AlertsInboxRepositoryImpl({required AlertsInboxRemoteDataSource remote}) : _remote = remote;

  final AlertsInboxRemoteDataSource _remote;

  @override
  Future<List<InboxAlert>> getAlerts() => _remote.getAlerts();

  @override
  Future<InboxAlert> markAlertRead(String id) => _remote.markAlertRead(id);
}
