import 'package:cryprice_frontend/core/navigation/app_section.dart';
import 'package:cryprice_frontend/features/push_notifications/domain/entities/push_notification_intent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushNotificationIntent.fromDeepLink', () {
    test('parses alerts hash route with alert_id', () {
      final intent = PushNotificationIntent.fromDeepLink(
        'https://app.cryprice.dev/#/alerts?alert_id=42',
      );

      expect(intent, isNotNull);
      expect(intent!.alertId, '42');
      expect(intent.targetSection, AppSection.alerts);
    });

    test('parses alerts hash route without alert_id', () {
      final intent = PushNotificationIntent.fromDeepLink(
        'https://app.cryprice.dev/#/alerts',
      );

      expect(intent, isNotNull);
      expect(intent!.alertId, isNull);
      expect(intent.targetSection, AppSection.alerts);
    });

    test('returns null for unrelated fragments', () {
      expect(
        PushNotificationIntent.fromDeepLink('https://app.cryprice.dev/#/portfolio'),
        isNull,
      );
    });
  });
}
