import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert.dart';
import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/alert_event_date.dart';
import 'package:cryprice_frontend/features/alerts/presentation/utils/health_factor_alert_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';

/// Plain-text lines mirroring [HealthFactorAlertCard] visible sections.
List<String> buildHealthFactorAlertVisibleLines(
  InboxAlert alert,
  AppLocalizations loc,
) {
  final payload = alert.healthFactorPayload;
  if (payload == null) {
    return const <String>[];
  }

  final isRecovery = alert.type == InboxAlertType.healthFactorRecovery;
  final typeLabel = isRecovery
      ? loc.alertsHfAlertTypeRecovery
      : loc.alertsHfAlertTypeBreach;
  final displayCopy = resolveHealthFactorAlertDisplayCopy(
    currentHfRaw: payload.healthFactor,
    alertType: alert.type,
    loc: loc,
  );
  final heroHf = formatHealthFactorWithIcon(payload.healthFactor, loc);
  final movement = getHealthFactorMovement(
    previousRaw: payload.previousHealthFactor,
    currentRaw: payload.healthFactor,
    loc: loc,
  );

  final lines = <String>[
    displayCopy.severityLabel,
    typeLabel,
    heroHf,
    formatAlertEventDate(alert.createdAt, loc),
    displayCopy.headline,
  ];

  if (displayCopy.explanation.trim().isNotEmpty) {
    lines.add(displayCopy.explanation.trim());
  }

  final wallet = formatWalletAddress(payload.walletId);
  if (wallet != null) {
    lines.add('${loc.alertsHfWallet}: $wallet');
  }

  final networkProtocol = formatNetworkProtocolLine(
    payload.networkId,
    payload.protocol,
  );
  if (networkProtocol != null) {
    lines.add(networkProtocol);
  }

  if (movement.showArrowLine) {
    final movementLabel = healthFactorMovementLabel(
      loc,
      kind: movement.kind,
      isRecovery: isRecovery,
    );
    if (movementLabel.isNotEmpty) {
      lines.add('${movement.trendIcon} $movementLabel');
    }
    lines.add(formatHealthFactorMovementLine(movement));
  }

  lines.add(loc.alertsHfThresholdLabel);
  lines.add(formatHealthFactor(payload.thresholdHf, loc));

  return lines;
}
