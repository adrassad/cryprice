import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/alert_event_date.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/alerts_inbox_labels.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/health_factor_alert_visible_content.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';

/// Builds plain text that mirrors the visible alert card content.
String formatAlertClipboardText(InboxAlert alert, AppLocalizations loc) {
  final lines = buildAlertVisibleLines(alert, loc);
  return lines.join('\n').trim();
}

List<String> buildAlertVisibleLines(InboxAlert alert, AppLocalizations loc) {
  return switch (alert.type) {
    InboxAlertType.healthFactorBreach ||
    InboxAlertType.healthFactorRecovery =>
      buildHealthFactorAlertVisibleLines(alert, loc),
    _ => _unsupportedAlertVisibleLines(alert, loc),
  };
}

List<String> _unsupportedAlertVisibleLines(
  InboxAlert alert,
  AppLocalizations loc,
) {
  final lines = <String>[
    alertsInboxSeverityLabel(loc, alert.severity),
    formatAlertEventDate(alert.createdAt, loc),
    alert.title,
  ];

  final message = alert.message.trim();
  if (message.isNotEmpty) {
    lines.add(message);
  }

  if (!InboxAlertType.isSupported(alert.type)) {
    lines.add(loc.alertsUnsupportedType);
  }

  return lines;
}
