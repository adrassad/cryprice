import 'package:cryprice_frontend/features/alerts/domain/entities/risk_news_payload.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';

String alertsInboxSeverityLabel(AppLocalizations loc, String severity) {
  return switch (severity.trim().toLowerCase()) {
    'critical' => loc.alertsRiskNewsSeverityCritical,
    'high' => loc.alertsRiskNewsSeverityHigh,
    'medium' => loc.alertsRiskNewsSeverityMedium,
    'low' => loc.alertsRiskNewsSeverityLow,
    'warning' => loc.alertsRiskNewsSeverityWarning,
    'info' => loc.alertsRiskNewsSeverityInfo,
    '' => loc.alertsRiskNewsSeverityInfo,
    _ => loc.alertsSeverityUnknown,
  };
}

String alertsInboxRiskNewsScopeLabel(AppLocalizations loc, RiskNewsPayload payload) {
  final scope = payload.targetScope?.trim().toLowerCase();
  return switch (scope) {
    'global' => loc.alertsRiskNewsScopeGlobal,
    'exposure' => loc.alertsRiskNewsScopeExposure,
    'admin_only' => loc.alertsRiskNewsScopeAdminOnly,
    null || '' => loc.alertsRiskNewsScopeGlobal,
    _ => loc.alertsScopeUnknown,
  };
}
