import 'package:cryprice_frontend/core/navigation/app_section.dart';

/// Parsed FCM data payload for in-app navigation.
class PushNotificationIntent {
  const PushNotificationIntent({
    required this.type,
    this.alertId,
    this.targetSection,
  });

  final String type;
  final String? alertId;
  final AppSection? targetSection;

  static PushNotificationIntent? fromData(Map<String, String> data) {
    final type = data['type']?.trim();
    if (type == null || type.isEmpty) {
      return null;
    }
    AppSection? section;
    if (type == 'health_factor_alert') {
      section = AppSection.portfolio;
    } else if (type == 'risk_news_alert') {
      section = AppSection.alerts;
    }
    return PushNotificationIntent(
      type: type,
      alertId: data['alert_id']?.trim(),
      targetSection: section,
    );
  }

  /// Parses backend webpush deep links such as `https://app.cryprice.dev/#/alerts?alert_id=42`.
  static PushNotificationIntent? fromDeepLink(String deepLink) {
    final routeUri = _parseAlertsFragmentRoute(deepLink);
    if (routeUri == null) {
      return null;
    }

    final alertId = routeUri.queryParameters['alert_id']?.trim();
    return PushNotificationIntent(
      type: 'risk_news_alert',
      alertId: alertId?.isNotEmpty == true ? alertId : null,
      targetSection: AppSection.alerts,
    );
  }

  static Uri? _parseAlertsFragmentRoute(String deepLink) {
    final uri = Uri.tryParse(deepLink.trim());
    if (uri == null) {
      return null;
    }

    final fragment = uri.fragment.trim();
    if (fragment.isEmpty) {
      return null;
    }

    final normalized = fragment.startsWith('/') ? fragment.substring(1) : fragment;
    final routeUri = Uri.parse('http://local/$normalized');
    if (routeUri.pathSegments.isEmpty || routeUri.pathSegments.first != 'alerts') {
      return null;
    }
    return routeUri;
  }
}
