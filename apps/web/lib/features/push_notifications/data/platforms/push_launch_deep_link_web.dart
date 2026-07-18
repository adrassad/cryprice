import 'package:cryprice_frontend/features/push_notifications/domain/entities/push_notification_intent.dart';
import 'package:web/web.dart' as web;

/// Reads `/#/alerts?alert_id=…` from the current browser URL.
String? readLaunchNotificationDeepLink() {
  final uri = Uri.base;
  final intent = PushNotificationIntent.fromDeepLink(uri.toString());
  if (intent == null) {
    return null;
  }
  return uri.toString();
}

/// Removes the hash fragment after the launch deep link was buffered.
void clearLaunchNotificationDeepLinkFromUrl() {
  final uri = Uri.base;
  if (PushNotificationIntent.fromDeepLink(uri.toString()) == null) {
    return;
  }
  final clean = uri.replace(fragment: '');
  web.window.history.replaceState(null, '', clean.toString());
}
