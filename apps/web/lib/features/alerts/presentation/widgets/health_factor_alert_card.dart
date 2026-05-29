import 'package:cryprice_frontend/features/alerts/domain/entities/health_factor_alert_payload.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/alert_event_date.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/health_factor_alert_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const double _kExpandedLayoutBreakpoint = 720;

/// Inbox card for `health_factor_breach` and `health_factor_recovery` alerts.
class HealthFactorAlertCard extends StatelessWidget {
  const HealthFactorAlertCard({
    super.key,
    required this.alert,
  });

  final InboxAlert alert;

  bool get _isRecovery => alert.type == InboxAlertType.healthFactorRecovery;

  @override
  Widget build(BuildContext context) {
    final payload = alert.healthFactorPayload;
    if (payload == null) {
      return const SizedBox.shrink();
    }

    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUnread = !alert.isRead;
    final visualStyle = getSeverityVisualStyle(
      alert.severity,
      colorScheme,
      currentHfRaw: payload.healthFactor,
      isUnread: isUnread,
    );
    final displayCopy = resolveHealthFactorAlertDisplayCopy(
      currentHfRaw: payload.healthFactor,
      alertType: alert.type,
      loc: loc,
    );
    final heroHf = formatHealthFactorWithIcon(payload.healthFactor, loc);
    final eventDateLabel = formatAlertEventDate(alert.createdAt, loc);
    final movement = getHealthFactorMovement(
      previousRaw: payload.previousHealthFactor,
      currentRaw: payload.healthFactor,
      loc: loc,
    );
    final typeLabel = _isRecovery
        ? loc.alertsHfAlertTypeRecovery
        : loc.alertsHfAlertTypeBreach;
    final severityLabel = displayCopy.severityLabel;

    return Card(
      key: Key('health_factor_alert_card_${alert.id}'),
      color: visualStyle.cardSurfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: visualStyle.borderColor.withValues(alpha: isUnread ? 0.95 : 0.55),
          width: isUnread ? 1.75 : 1.25,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final useExpandedLayout = constraints.maxWidth >= _kExpandedLayoutBreakpoint;

            if (useExpandedLayout) {
              return _ExpandedCardLayout(
                alert: alert,
                payload: payload,
                loc: loc,
                theme: theme,
                colorScheme: colorScheme,
                visualStyle: visualStyle,
                heroHf: heroHf,
                eventDateLabel: eventDateLabel,
                severityLabel: severityLabel,
                typeLabel: typeLabel,
                movement: movement,
                displayCopy: displayCopy,
                isRecovery: _isRecovery,
                isUnread: isUnread,
              );
            }

            return _CompactCardLayout(
              alert: alert,
              payload: payload,
              loc: loc,
              theme: theme,
              colorScheme: colorScheme,
              visualStyle: visualStyle,
              heroHf: heroHf,
              eventDateLabel: eventDateLabel,
              severityLabel: severityLabel,
              typeLabel: typeLabel,
              movement: movement,
              displayCopy: displayCopy,
              isRecovery: _isRecovery,
              isUnread: isUnread,
            );
          },
        ),
      ),
    );
  }
}

class _ExpandedCardLayout extends StatelessWidget {
  const _ExpandedCardLayout({
    required this.alert,
    required this.payload,
    required this.loc,
    required this.theme,
    required this.colorScheme,
    required this.visualStyle,
    required this.heroHf,
    required this.eventDateLabel,
    required this.severityLabel,
    required this.typeLabel,
    required this.movement,
    required this.displayCopy,
    required this.isRecovery,
    required this.isUnread,
  });

  final InboxAlert alert;
  final HealthFactorAlertPayload payload;
  final AppLocalizations loc;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final HealthFactorSeverityVisualStyle visualStyle;
  final String heroHf;
  final String eventDateLabel;
  final String severityLabel;
  final String typeLabel;
  final HealthFactorMovement movement;
  final HealthFactorAlertDisplayCopy displayCopy;
  final bool isRecovery;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  Text(
                    heroHf,
                    key: const Key('health_factor_alert_hero_hf'),
                    style: GoogleFonts.montserrat(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: visualStyle.hfAccentColor,
                      height: 1,
                    ),
                  ),
                  Text(
                    eventDateLabel,
                    key: Key('health_factor_alert_header_date_${alert.id}'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _BadgeRow(
              severityLabel: severityLabel,
              typeLabel: typeLabel,
              visualStyle: visualStyle,
              isRecovery: isRecovery,
              colorScheme: colorScheme,
              isUnread: isUnread,
              alignEnd: true,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _ExpandedLeftSection(
                alert: alert,
                payload: payload,
                loc: loc,
                theme: theme,
                colorScheme: colorScheme,
                displayCopy: displayCopy,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: _MovementSection(
                movement: movement,
                isRecovery: isRecovery,
                loc: loc,
                alignEnd: false,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: _ThresholdSection(
                payload: payload,
                loc: loc,
                alignEnd: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompactCardLayout extends StatelessWidget {
  const _CompactCardLayout({
    required this.alert,
    required this.payload,
    required this.loc,
    required this.theme,
    required this.colorScheme,
    required this.visualStyle,
    required this.heroHf,
    required this.eventDateLabel,
    required this.severityLabel,
    required this.typeLabel,
    required this.movement,
    required this.displayCopy,
    required this.isRecovery,
    required this.isUnread,
  });

  final InboxAlert alert;
  final HealthFactorAlertPayload payload;
  final AppLocalizations loc;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final HealthFactorSeverityVisualStyle visualStyle;
  final String heroHf;
  final String eventDateLabel;
  final String severityLabel;
  final String typeLabel;
  final HealthFactorMovement movement;
  final HealthFactorAlertDisplayCopy displayCopy;
  final bool isRecovery;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final wallet = formatWalletAddress(payload.walletId);
    final networkProtocol = formatNetworkProtocolLine(
      payload.networkId,
      payload.protocol,
    );
    final bodyStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurface,
      height: 1.35,
    );
    final mutedStyle = theme.textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.35,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heroHf,
                key: const Key('health_factor_alert_hero_hf'),
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: visualStyle.hfAccentColor,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                eventDateLabel,
                key: Key('health_factor_alert_header_date_${alert.id}'),
                style: mutedStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Chip(
                    label: severityLabel,
                    background: visualStyle.severityBackground,
                    foreground: visualStyle.severityForeground,
                  ),
                  _Chip(
                    label: typeLabel,
                    background: isRecovery
                        ? colorScheme.primaryContainer
                        : colorScheme.errorContainer.withValues(alpha: 0.65),
                    foreground: isRecovery
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onErrorContainer,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                displayCopy.headline,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              if (displayCopy.explanation.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  displayCopy.explanation.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: mutedStyle,
                ),
              ],
              if (wallet != null) ...[
                const SizedBox(height: 6),
                Text(
                  '💼 $wallet',
                  style: bodyStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (networkProtocol != null) ...[
                const SizedBox(height: 4),
                Text(
                  '🌐 $networkProtocol',
                  style: bodyStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 118,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isUnread)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Icon(
                    Icons.fiber_manual_record,
                    key: const Key('health_factor_alert_unread_dot'),
                    size: 10,
                    color: colorScheme.error,
                  ),
                ),
              _MovementSection(
                movement: movement,
                isRecovery: isRecovery,
                loc: loc,
                alignEnd: true,
              ),
              const SizedBox(height: 8),
              _ThresholdSection(
                payload: payload,
                loc: loc,
                alignEnd: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpandedLeftSection extends StatelessWidget {
  const _ExpandedLeftSection({
    required this.alert,
    required this.payload,
    required this.loc,
    required this.theme,
    required this.colorScheme,
    required this.displayCopy,
  });

  final InboxAlert alert;
  final HealthFactorAlertPayload payload;
  final AppLocalizations loc;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final HealthFactorAlertDisplayCopy displayCopy;

  @override
  Widget build(BuildContext context) {
    final wallet = formatWalletAddress(payload.walletId);
    final networkProtocol = formatNetworkProtocolLine(
      payload.networkId,
      payload.protocol,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
      height: 1.4,
    );
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayCopy.headline,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        if (displayCopy.explanation.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            displayCopy.explanation.trim(),
            style: mutedStyle,
          ),
        ],
        if (wallet != null) ...[
          const SizedBox(height: 10),
          Text(
            '${loc.alertsHfWallet}: $wallet',
            style: bodyStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (networkProtocol != null) ...[
          const SizedBox(height: 6),
          Text(
            networkProtocol,
            style: bodyStyle,
          ),
        ],
      ],
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({
    required this.severityLabel,
    required this.typeLabel,
    required this.visualStyle,
    required this.isRecovery,
    required this.colorScheme,
    required this.isUnread,
    required this.alignEnd,
  });

  final String severityLabel;
  final String typeLabel;
  final HealthFactorSeverityVisualStyle visualStyle;
  final bool isRecovery;
  final ColorScheme colorScheme;
  final bool isUnread;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: alignEnd ? WrapAlignment.end : WrapAlignment.start,
          children: [
            _Chip(
              label: severityLabel,
              background: visualStyle.severityBackground,
              foreground: visualStyle.severityForeground,
            ),
            _Chip(
              label: typeLabel,
              background: isRecovery
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer.withValues(alpha: 0.65),
              foreground: isRecovery
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onErrorContainer,
            ),
          ],
        ),
        if (isUnread)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              Icons.fiber_manual_record,
              key: const Key('health_factor_alert_unread_dot'),
              size: 10,
              color: colorScheme.error,
            ),
          ),
      ],
    );
  }
}

class _MovementSection extends StatelessWidget {
  const _MovementSection({
    required this.movement,
    required this.isRecovery,
    required this.loc,
    required this.alignEnd,
  });

  final HealthFactorMovement movement;
  final bool isRecovery;
  final AppLocalizations loc;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    if (!movement.showArrowLine) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final movementLabel = healthFactorMovementLabel(
      loc,
      kind: movement.kind,
      isRecovery: isRecovery,
    );
    final crossAxis = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;

    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          '${movement.trendIcon} $movementLabel',
          textAlign: textAlign,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          formatHealthFactorMovementLine(movement),
          textAlign: textAlign,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ThresholdSection extends StatelessWidget {
  const _ThresholdSection({
    required this.payload,
    required this.loc,
    required this.alignEnd,
  });

  final HealthFactorAlertPayload payload;
  final AppLocalizations loc;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final crossAxis = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;

    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          loc.alertsHfThresholdLabel,
          textAlign: textAlign,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          formatHealthFactor(payload.thresholdHf, loc),
          textAlign: textAlign,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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
