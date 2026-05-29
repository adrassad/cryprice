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
