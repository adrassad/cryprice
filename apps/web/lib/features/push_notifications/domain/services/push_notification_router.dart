import 'package:cryprice_frontend/core/navigation/push_navigation_bridge.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/entities/push_notification_intent.dart';

class PushNotificationRouter {
  PushNotificationRouter({required PushNavigationBridge navigationBridge})
      : _navigationBridge = navigationBridge;

  final PushNavigationBridge _navigationBridge;

  void route(Map<String, String> data) {
    routeIntent(PushNotificationIntent.fromData(data));
  }

  void routeIntent(PushNotificationIntent? intent) {
    if (intent == null) {
      return;
    }

    final alertId = intent.alertId?.trim();
    if (alertId != null && alertId.isNotEmpty) {
      _navigationBridge.openAlerts(alertId: alertId);
      return;
    }

    switch (intent.type) {
      case 'health_factor_alert':
        _navigationBridge.openPortfolio();
      case 'risk_news_alert':
        _navigationBridge.openAlerts();
      default:
        break;
    }
  }
}
