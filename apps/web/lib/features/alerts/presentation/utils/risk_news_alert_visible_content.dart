import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/risk_news_payload.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/alert_event_date.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/alerts_inbox_labels.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/risk_news_source_link.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';

/// Plain-text lines mirroring [RiskNewsAlertCard] visible sections.
List<String> buildRiskNewsAlertVisibleLines(
  InboxAlert alert,
  AppLocalizations loc,
) {
  final payload = alert.riskNewsPayload;
  if (payload == null) {
    return const <String>[];
  }

  final lines = <String>[
    alertsInboxSeverityLabel(loc, alert.severity),
    alertsInboxRiskNewsScopeLabel(loc, payload),
    formatAlertEventDate(alert.createdAt, loc),
    alert.title,
  ];

  final message = alert.message.trim();
  if (message.isNotEmpty) {
    lines.add(message);
  }

  if (payload.isGlobalScope && payload.globalReason?.trim().isNotEmpty == true) {
    lines.add('');
    lines.add(loc.alertsRiskNewsGlobalReason);
    lines.add(payload.globalReason!.trim());
  }

  if (payload.isExposureScope) {
    final exposureLines = riskNewsExposureVisibleLines(payload, loc);
    if (exposureLines.isNotEmpty) {
      lines.add('');
      lines.addAll(exposureLines);
    }
  } else {
    final affectedLines = riskNewsAffectedVisibleLines(payload, loc);
    if (affectedLines.isNotEmpty) {
      lines.add('');
      lines.addAll(affectedLines);
    }
  }

  lines.add('');
  lines.add(riskNewsSourceVisibleLine(payload, loc));

  lines.add('');
  lines.add(loc.alertsRiskNewsDisclaimer);

  return lines;
}

List<String> riskNewsExposureVisibleLines(
  RiskNewsPayload payload,
  AppLocalizations loc,
) {
  final lines = <String>[];

  if (payload.matchedAssets.isNotEmpty) {
    lines.add(
      riskNewsLabeledValueLine(
        loc.alertsRiskNewsMatchedAsset,
        payload.matchedAssets,
      ),
    );
  }
  if (payload.matchedProtocols.isNotEmpty) {
    lines.add(
      riskNewsLabeledValueLine(
        loc.alertsRiskNewsMatchedProtocol,
        payload.matchedProtocols,
      ),
    );
  }
  if (payload.matchedChains.isNotEmpty) {
    lines.add(
      riskNewsLabeledValueLine(
        loc.alertsRiskNewsMatchedChain,
        payload.matchedChains,
      ),
    );
  }

  final confidence = payload.matchConfidence?.trim();
  if (confidence != null && confidence.isNotEmpty) {
    lines.add(loc.alertsRiskNewsMatchConfidence(confidence));
  }

  return lines;
}

List<String> riskNewsAffectedVisibleLines(
  RiskNewsPayload payload,
  AppLocalizations loc,
) {
  if (payload.isExposureScope) {
    return const <String>[];
  }

  final sections = <List<String>>[];
  if (payload.affectedProtocols.isNotEmpty) {
    sections.add(
      riskNewsLabeledChipSectionLines(
        loc.alertsRiskNewsAffectedProtocols,
        payload.affectedProtocols,
      ),
    );
  }
  if (payload.affectedAssets.isNotEmpty) {
    sections.add(
      riskNewsLabeledChipSectionLines(
        loc.alertsRiskNewsAffectedAssets,
        payload.affectedAssets,
      ),
    );
  }
  if (payload.affectedChains.isNotEmpty) {
    sections.add(
      riskNewsLabeledChipSectionLines(
        loc.alertsRiskNewsAffectedChains,
        payload.affectedChains,
      ),
    );
  }

  return _joinSections(sections);
}

List<String> riskNewsLabeledChipSectionLines(String label, List<String> values) {
  return <String>[label, values.join(', ')];
}

String riskNewsLabeledValueLine(String label, List<String> values) {
  return '$label: ${values.join(', ')}';
}

String riskNewsSourceVisibleLine(RiskNewsPayload payload, AppLocalizations loc) {
  final uri = RiskNewsSourceLink.displayableUri(payload.primarySourceUrl);
  if (uri == null) {
    return loc.alertsRiskNewsSourceUnavailable;
  }

  final title = payload.primarySourceTitle?.trim();
  final label = title != null && title.isNotEmpty ? title : uri.host;
  return '${loc.alertsRiskNewsSource}: $label';
}

List<String> _joinSections(List<List<String>> sections) {
  if (sections.isEmpty) {
    return const <String>[];
  }

  final lines = <String>[];
  for (int i = 0; i < sections.length; i++) {
    lines.addAll(sections[i]);
    if (i < sections.length - 1) {
      lines.add('');
    }
  }
  return lines;
}
