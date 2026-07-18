import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/risk_news_payload.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/alert_event_date.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/alerts_inbox_labels.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/risk_news_source_link.dart';
import 'package:cryprice_frontend/features/alerts/presentation/widgets/alert_card_header_trailing.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Rich DeFi risk card for [InboxAlert] items of type `risk_news`.
class RiskNewsAlertCard extends StatelessWidget {
  const RiskNewsAlertCard({
    super.key,
    required this.alert,
  });

  final InboxAlert alert;

  @override
  Widget build(BuildContext context) {
    final payload = alert.riskNewsPayload;
    if (payload == null) {
      return const SizedBox.shrink();
    }

    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final severityStyle = _RiskNewsSeverityStyle.fromSeverity(alert.severity, colorScheme);
    final isUnread = !alert.isRead;

    return Card(
      key: Key('risk_news_alert_card_${alert.id}'),
      color: isUnread
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isUnread
              ? colorScheme.primary.withValues(alpha: 0.45)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: isUnread ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderRow(
              alertId: alert.id,
              severityLabel: alertsInboxSeverityLabel(loc, alert.severity),
              severityStyle: severityStyle,
              scopeLabel: alertsInboxRiskNewsScopeLabel(loc, payload),
              eventDateLabel: formatAlertEventDate(alert.createdAt, loc),
              isUnread: isUnread,
            ),
            const SizedBox(height: 10),
            Text(
              alert.title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            if (alert.message.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                alert.message.trim(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            if (payload.isGlobalScope && payload.globalReason?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 10),
              _LabeledChipSection(
                label: loc.alertsRiskNewsGlobalReason,
                values: [payload.globalReason!.trim()],
              ),
            ],
            if (payload.isExposureScope) ...[
              const SizedBox(height: 10),
              _ExposureBlock(payload: payload, loc: loc),
            ],
            ..._affectedSections(payload, loc),
            const SizedBox(height: 10),
            _SourceLinkRow(
              payload: payload,
              loc: loc,
              onOpen: () => _openSourceLink(context, payload),
            ),
            const SizedBox(height: 8),
            Text(
              loc.alertsRiskNewsDisclaimer,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _affectedSections(RiskNewsPayload payload, AppLocalizations loc) {
    if (payload.isExposureScope) {
      return const <Widget>[];
    }

    final sections = <Widget>[];
    if (payload.affectedProtocols.isNotEmpty) {
      sections.add(
        _LabeledChipSection(
          label: loc.alertsRiskNewsAffectedProtocols,
          values: payload.affectedProtocols,
        ),
      );
    }
    if (payload.affectedAssets.isNotEmpty) {
      sections.add(
        _LabeledChipSection(
          label: loc.alertsRiskNewsAffectedAssets,
          values: payload.affectedAssets,
        ),
      );
    }
    if (payload.affectedChains.isNotEmpty) {
      sections.add(
        _LabeledChipSection(
          label: loc.alertsRiskNewsAffectedChains,
          values: payload.affectedChains,
        ),
      );
    }
    if (sections.isEmpty) {
      return const <Widget>[];
    }
    return <Widget>[
      const SizedBox(height: 10),
      for (int i = 0; i < sections.length; i++) ...[
        sections[i],
        if (i < sections.length - 1) const SizedBox(height: 8),
      ],
    ];
  }

  static Future<void> _openSourceLink(BuildContext context, RiskNewsPayload payload) async {
    final uri = RiskNewsSourceLink.displayableUri(payload.primarySourceUrl);
    if (uri == null) {
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.alertsRiskNewsSourceOpenFailed)),
      );
    }
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.alertId,
    required this.severityLabel,
    required this.severityStyle,
    required this.scopeLabel,
    required this.eventDateLabel,
    required this.isUnread,
  });

  final String alertId;
  final String severityLabel;
  final _RiskNewsSeverityStyle severityStyle;
  final String scopeLabel;
  final String eventDateLabel;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _BadgeChip(
                label: severityLabel,
                background: severityStyle.background,
                foreground: severityStyle.foreground,
              ),
              _BadgeChip(
                label: scopeLabel,
                background: Theme.of(context).colorScheme.surfaceContainerHighest,
                foreground: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        AlertCardHeaderTrailing(
          dateLabel: eventDateLabel,
          dateKey: Key('risk_news_alert_header_date_$alertId'),
          isUnread: isUnread,
          unreadKey: const Key('risk_news_alert_unread_dot'),
        ),
      ],
    );
  }
}

class _ExposureBlock extends StatelessWidget {
  const _ExposureBlock({
    required this.payload,
    required this.loc,
  });

  final RiskNewsPayload payload;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const Key('risk_news_alert_exposure_block'),
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (payload.matchedAssets.isNotEmpty)
            _ExposureLine(
              label: loc.alertsRiskNewsMatchedAsset,
              value: payload.matchedAssets,
            ),
          if (payload.matchedProtocols.isNotEmpty)
            _ExposureLine(
              label: loc.alertsRiskNewsMatchedProtocol,
              value: payload.matchedProtocols,
            ),
          if (payload.matchedChains.isNotEmpty)
            _ExposureLine(
              label: loc.alertsRiskNewsMatchedChain,
              value: payload.matchedChains,
            ),
          if (payload.matchConfidence?.trim().isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                loc.alertsRiskNewsMatchConfidence(payload.matchConfidence!.trim()),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExposureLine extends StatelessWidget {
  const _ExposureLine({
    required this.label,
    required this.value,
  });

  final String label;
  final List<String> value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value.join(', ')),
          ],
        ),
      ),
    );
  }
}

class _LabeledChipSection extends StatelessWidget {
  const _LabeledChipSection({
    required this.label,
    required this.values,
  });

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: values
              .map(
                (value) => _BadgeChip(
                  label: value,
                  background: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  foreground: colorScheme.onSecondaryContainer,
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _SourceLinkRow extends StatelessWidget {
  const _SourceLinkRow({
    required this.payload,
    required this.loc,
    required this.onOpen,
  });

  final RiskNewsPayload payload;
  final AppLocalizations loc;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final uri = RiskNewsSourceLink.displayableUri(payload.primarySourceUrl);

    if (uri == null) {
      return Text(
        loc.alertsRiskNewsSourceUnavailable,
        key: const Key('risk_news_alert_source_unavailable'),
        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      );
    }

    final title = payload.primarySourceTitle?.trim();
    final label = title != null && title.isNotEmpty ? title : uri.host;

    return InkWell(
      key: const Key('risk_news_alert_source_link'),
      onTap: onOpen,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(Icons.open_in_new, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${loc.alertsRiskNewsSource}: $label',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

class _RiskNewsSeverityStyle {
  const _RiskNewsSeverityStyle({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;

  static _RiskNewsSeverityStyle fromSeverity(String severity, ColorScheme colors) {
    return switch (severity.trim().toLowerCase()) {
      'critical' => _RiskNewsSeverityStyle(
          background: colors.errorContainer,
          foreground: colors.onErrorContainer,
        ),
      'high' => _RiskNewsSeverityStyle(
          background: colors.error.withValues(alpha: 0.18),
          foreground: colors.error,
        ),
      'medium' => _RiskNewsSeverityStyle(
          background: colors.tertiaryContainer,
          foreground: colors.onTertiaryContainer,
        ),
      'low' => _RiskNewsSeverityStyle(
          background: colors.surfaceContainerHighest,
          foreground: colors.onSurfaceVariant,
        ),
      'warning' => _RiskNewsSeverityStyle(
          background: colors.tertiaryContainer,
          foreground: colors.onTertiaryContainer,
        ),
      'info' => _RiskNewsSeverityStyle(
          background: colors.primaryContainer,
          foreground: colors.onPrimaryContainer,
        ),
      _ => _RiskNewsSeverityStyle(
          background: colors.surfaceContainerHighest,
          foreground: colors.onSurfaceVariant,
        ),
    };
  }
}
