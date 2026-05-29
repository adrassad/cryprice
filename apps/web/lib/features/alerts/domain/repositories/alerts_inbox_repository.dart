import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';

abstract class AlertsInboxRepository {
  Future<List<InboxAlert>> getAlerts();

  Future<InboxAlert> markAlertRead(String id);
}
