import 'package:cryprice_frontend/core/navigation/push_navigation_bridge.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/services/push_notification_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushNotificationRouter', () {
    late _RecordingBridge bridge;
    late PushNotificationRouter router;

    setUp(() {
      bridge = _RecordingBridge();
      router = PushNotificationRouter(navigationBridge: bridge);
    });

    test('health_factor_alert without alert_id opens portfolio', () {
      router.route({'type': 'health_factor_alert'});

      expect(bridge.portfolioOpens, 1);
      expect(bridge.alertsOpens, 0);
    });

    test('health_factor_alert with alert_id opens alerts focus', () {
      router.route({'type': 'health_factor_alert', 'alert_id': 'a1'});

      expect(bridge.portfolioOpens, 0);
      expect(bridge.alertsOpens, 1);
      expect(bridge.lastAlertId, 'a1');
    });

    test('risk_news_alert opens alerts', () {
      router.route({'type': 'risk_news_alert'});

      expect(bridge.portfolioOpens, 0);
      expect(bridge.alertsOpens, 1);
      expect(bridge.lastAlertId, isNull);
    });

    test('risk_news_alert with alert_id passes alert_id to bridge', () {
      router.route({'type': 'risk_news_alert', 'alert_id': '42'});

      expect(bridge.alertsOpens, 1);
      expect(bridge.lastAlertId, '42');
    });

    test('missing type is no-op', () {
      router.route({'alert_id': 'a1'});

      expect(bridge.portfolioOpens, 0);
      expect(bridge.alertsOpens, 0);
    });
  });
}

class _RecordingBridge implements PushNavigationBridge {
  int portfolioOpens = 0;
  int alertsOpens = 0;
  String? lastAlertId;

  @override
  void openPortfolio() => portfolioOpens++;

  @override
  void openAlerts({String? alertId}) {
    alertsOpens++;
    lastAlertId = alertId;
  }
}
