import 'package:cryprice_frontend/features/alerts/domain/entities/inbox_alert_type.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum HealthFactorSemanticState {
  liquidation,
  critical,
  warning,
  recovery,
  safe,
}

class HealthFactorAlertDisplayCopy {
  const HealthFactorAlertDisplayCopy({
    required this.headline,
    required this.explanation,
    required this.severityLabel,
  });

  final String headline;
  final String explanation;
  final String severityLabel;
}

const double _kHealthFactorCriticalHf = 1.2;

enum HealthFactorMovementKind {
  improved,
  decreased,
  unchanged,
  currentOnly,
}

class HealthFactorMovement {
  const HealthFactorMovement({
    required this.kind,
    required this.trendIcon,
    required this.previousDisplay,
    required this.currentDisplay,
    required this.showArrowLine,
  });

  final HealthFactorMovementKind kind;
  final String trendIcon;
  final String previousDisplay;
  final String currentDisplay;
  final bool showArrowLine;
}

class HealthFactorSeverityVisualStyle {
  const HealthFactorSeverityVisualStyle({
    required this.borderColor,
    required this.severityBackground,
    required this.severityForeground,
    required this.hfAccentColor,
    required this.cardSurfaceColor,
  });

  final Color borderColor;
  final Color severityBackground;
  final Color severityForeground;
  final Color hfAccentColor;
  final Color cardSurfaceColor;
}

const Map<String, String> _networkSlugLabels = <String, String>{
  'ethereum': 'Ethereum',
  'eth': 'Ethereum',
  'mainnet': 'Ethereum',
  'arbitrum': 'Arbitrum',
  'arb': 'Arbitrum',
  'arbitrum-one': 'Arbitrum',
  'base': 'Base',
  'avalanche': 'Avalanche',
  'avax': 'Avalanche',
  'bnb': 'BNB Chain',
  'bsc': 'BNB Chain',
  'binance': 'BNB Chain',
  'polygon': 'Polygon',
  'matic': 'Polygon',
  'optimism': 'Optimism',
  'op': 'Optimism',
};

const Map<int, String> _networkChainIdLabels = <int, String>{
  1: 'Ethereum',
  10: 'Optimism',
  56: 'BNB Chain',
  137: 'Polygon',
  8453: 'Base',
  42161: 'Arbitrum',
  42170: 'Arbitrum',
  43114: 'Avalanche',
};

const Map<String, String> _protocolLabels = <String, String>{
  'aave': 'Aave V3',
  'aave-v3': 'Aave V3',
  'aave_v3': 'Aave V3',
  'compound': 'Compound V3',
  'compound-v3': 'Compound V3',
  'compound_v3': 'Compound V3',
};

double? resolveHealthFactorNumber(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  if (trimmed.toLowerCase() == 'infinity') {
    return double.infinity;
  }
  return double.tryParse(trimmed);
}

String formatHealthFactor(String? raw, AppLocalizations loc) {
  final value = resolveHealthFactorNumber(raw);
  if (value == null) {
    return loc.portfolioHealthFactorUnavailable;
  }
  if (value.isInfinite) {
    return 'Infinity';
  }
  return value.toStringAsFixed(2);
}

String getHealthFactorIcon(String? raw) {
  final value = resolveHealthFactorNumber(raw);
  if (value == null) {
    return '';
  }
  if (value.isInfinite) {
    return '♾️';
  }
  if (value > 2) {
    return '💚';
  }
  if (value > 1.5) {
    return '💛';
  }
  if (value > 1.2) {
    return '🧡';
  }
  if (value > 1) {
    return '❤️';
  }
  return '💔';
}

HealthFactorSemanticState resolveHealthFactorSemanticState({
  required String? currentHfRaw,
  required String alertType,
}) {
  if (alertType == InboxAlertType.healthFactorRecovery) {
    return HealthFactorSemanticState.recovery;
  }

  final value = resolveHealthFactorNumber(currentHfRaw);
  if (value == null || value.isInfinite) {
    return HealthFactorSemanticState.safe;
  }
  if (value <= 1) {
    return HealthFactorSemanticState.liquidation;
  }
  if (value < _kHealthFactorCriticalHf) {
    return HealthFactorSemanticState.critical;
  }
  return HealthFactorSemanticState.warning;
}

HealthFactorAlertDisplayCopy resolveHealthFactorAlertDisplayCopy({
  required String? currentHfRaw,
  required String alertType,
  required AppLocalizations loc,
}) {
  final state = resolveHealthFactorSemanticState(
    currentHfRaw: currentHfRaw,
    alertType: alertType,
  );

  switch (state) {
    case HealthFactorSemanticState.liquidation:
      return HealthFactorAlertDisplayCopy(
        headline: loc.alertsHfLiquidationHeadline,
        explanation: loc.alertsHfLiquidationExplanation,
        severityLabel: '🚨 ${loc.alertsHfLiquidationHeadline}',
      );
    case HealthFactorSemanticState.critical:
      return HealthFactorAlertDisplayCopy(
        headline: loc.alertsHfCriticalHeadline,
        explanation: loc.alertsHfBelowAlertThreshold,
        severityLabel: formatHealthFactorSeverityLabel(loc, 'critical'),
      );
    case HealthFactorSemanticState.warning:
      return HealthFactorAlertDisplayCopy(
        headline: loc.alertsHfBelowAlertThreshold,
        explanation: '',
        severityLabel: formatHealthFactorSeverityLabel(loc, 'warning'),
      );
    case HealthFactorSemanticState.recovery:
      return HealthFactorAlertDisplayCopy(
        headline: loc.alertsHfRecoveryHeadline,
        explanation: loc.alertsHfRecoveredAboveAlertThreshold,
        severityLabel: formatHealthFactorSeverityLabel(loc, 'info'),
      );
    case HealthFactorSemanticState.safe:
      return HealthFactorAlertDisplayCopy(
        headline: loc.alertsHfBelowAlertThreshold,
        explanation: '',
        severityLabel: formatHealthFactorSeverityLabel(loc, 'warning'),
      );
  }
}

String formatHealthFactorWithIcon(String? raw, AppLocalizations loc) {
  final formatted = formatHealthFactor(raw, loc);
  if (formatted == loc.portfolioHealthFactorUnavailable) {
    return formatted;
  }
  final icon = getHealthFactorIcon(raw);
  if (icon.isEmpty) {
    return formatted;
  }
  return '$icon $formatted';
}

String formatHealthFactorSeverityLabel(AppLocalizations loc, String severity) {
  final label = switch (severity.trim().toLowerCase()) {
    'critical' => loc.alertsRiskNewsSeverityCritical,
    'high' => loc.alertsRiskNewsSeverityHigh,
    'medium' => loc.alertsRiskNewsSeverityMedium,
    'low' => loc.alertsRiskNewsSeverityLow,
    'warning' => loc.alertsRiskNewsSeverityWarning,
    'info' => loc.alertsRiskNewsSeverityInfo,
    '' => loc.alertsRiskNewsSeverityInfo,
    _ => loc.alertsSeverityUnknown,
  };

  final emoji = switch (severity.trim().toLowerCase()) {
    'critical' => '🚨',
    'high' => '🔴',
    'warning' => '⚠️',
    'medium' => '🟠',
    'low' => '🟡',
    'info' => 'ℹ️',
    _ => '',
  };

  if (emoji.isEmpty) {
    return label;
  }
  return '$emoji $label';
}

String? formatWalletAddress(String? walletId) {
  final trimmed = walletId?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  if (trimmed.length > 12) {
    return shortenPortfolioAddress(trimmed);
  }
  return trimmed;
}

String? formatProtocolName(String? protocol) {
  final key = protocol?.trim().toLowerCase();
  if (key == null || key.isEmpty) {
    return null;
  }
  final mapped = _protocolLabels[key];
  if (mapped != null) {
    return mapped;
  }
  return _titleCaseSlug(key);
}

String? formatNetworkName(String? networkId) {
  final raw = networkId?.trim();
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final slug = _networkSlugLabels[raw.toLowerCase()];
  if (slug != null) {
    return slug;
  }

  final numeric = int.tryParse(raw);
  if (numeric != null) {
    return _networkChainIdLabels[numeric] ?? raw;
  }

  return _titleCaseSlug(
    raw.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' '),
  );
}

String? formatNetworkProtocolLine(String? networkId, String? protocol) {
  final network = formatNetworkName(networkId);
  final protocolName = formatProtocolName(protocol);

  if (network != null && protocolName != null) {
    return '$network · $protocolName';
  }
  return network ?? protocolName;
}

HealthFactorMovement getHealthFactorMovement({
  required String? previousRaw,
  required String? currentRaw,
  required AppLocalizations loc,
}) {
  final currentDisplay = formatHealthFactorWithIcon(currentRaw, loc);
  final previousNumber = resolveHealthFactorNumber(previousRaw);
  final currentNumber = resolveHealthFactorNumber(currentRaw);

  if (previousNumber == null || currentNumber == null) {
    return HealthFactorMovement(
      kind: HealthFactorMovementKind.currentOnly,
      trendIcon: '',
      previousDisplay: '',
      currentDisplay: currentDisplay,
      showArrowLine: false,
    );
  }

  final previousDisplay = formatHealthFactorWithIcon(previousRaw, loc);
  HealthFactorMovementKind kind;
  String trendIcon;

  if (currentNumber > previousNumber) {
    kind = HealthFactorMovementKind.improved;
    trendIcon = '📈';
  } else if (currentNumber < previousNumber) {
    kind = HealthFactorMovementKind.decreased;
    trendIcon = '📉';
  } else {
    kind = HealthFactorMovementKind.unchanged;
    trendIcon = '➖';
  }

  return HealthFactorMovement(
    kind: kind,
    trendIcon: trendIcon,
    previousDisplay: previousDisplay,
    currentDisplay: currentDisplay,
    showArrowLine: true,
  );
}

String healthFactorMovementLabel(
  AppLocalizations loc, {
  required HealthFactorMovementKind kind,
  required bool isRecovery,
}) {
  return switch (kind) {
    HealthFactorMovementKind.improved =>
      isRecovery ? loc.alertsHfMovementImproved : loc.alertsHfMovementChanged,
    HealthFactorMovementKind.decreased => loc.alertsHfMovementDecreased,
    HealthFactorMovementKind.unchanged => loc.alertsHfMovementUnchanged,
    HealthFactorMovementKind.currentOnly => '',
  };
}

String formatHealthFactorMovementLine(HealthFactorMovement movement) {
  if (!movement.showArrowLine) {
    return movement.currentDisplay;
  }
  return '${movement.previousDisplay} → ${movement.currentDisplay}';
}

HealthFactorSeverityVisualStyle getSeverityVisualStyle(
  String severity,
  ColorScheme colors, {
  String? currentHfRaw,
  bool isUnread = false,
}) {
  final hfAccent = resolveHealthFactorAccentColor(currentHfRaw, colors);
  final normalized = severity.trim().toLowerCase();
  final baseSurface = isUnread
      ? colors.surfaceContainerHigh
      : colors.surfaceContainerHighest.withValues(alpha: 0.65);

  return switch (normalized) {
    'critical' => HealthFactorSeverityVisualStyle(
        borderColor: colors.error,
        severityBackground: colors.errorContainer,
        severityForeground: colors.onErrorContainer,
        hfAccentColor: hfAccent,
        cardSurfaceColor: Color.alphaBlend(
          colors.error.withValues(alpha: 0.08),
          baseSurface,
        ),
      ),
    'high' => HealthFactorSeverityVisualStyle(
        borderColor: colors.error.withValues(alpha: 0.82),
        severityBackground: colors.error.withValues(alpha: 0.18),
        severityForeground: colors.error,
        hfAccentColor: hfAccent,
        cardSurfaceColor: Color.alphaBlend(
          colors.error.withValues(alpha: 0.06),
          baseSurface,
        ),
      ),
    'medium' => HealthFactorSeverityVisualStyle(
        borderColor: colors.tertiary.withValues(alpha: 0.9),
        severityBackground: colors.tertiaryContainer,
        severityForeground: colors.onTertiaryContainer,
        hfAccentColor: hfAccent,
        cardSurfaceColor: Color.alphaBlend(
          colors.tertiary.withValues(alpha: 0.08),
          baseSurface,
        ),
      ),
    'warning' => HealthFactorSeverityVisualStyle(
        borderColor: colors.tertiary.withValues(alpha: 0.75),
        severityBackground: colors.tertiaryContainer.withValues(alpha: 0.85),
        severityForeground: colors.onTertiaryContainer,
        hfAccentColor: hfAccent,
        cardSurfaceColor: Color.alphaBlend(
          colors.tertiary.withValues(alpha: 0.07),
          baseSurface,
        ),
      ),
    'low' => HealthFactorSeverityVisualStyle(
        borderColor: colors.primary.withValues(alpha: 0.45),
        severityBackground: colors.surfaceContainerHighest,
        severityForeground: colors.onSurfaceVariant,
        hfAccentColor: hfAccent,
        cardSurfaceColor: baseSurface,
      ),
    'info' => HealthFactorSeverityVisualStyle(
        borderColor: colors.primary.withValues(alpha: 0.65),
        severityBackground: colors.primaryContainer,
        severityForeground: colors.onPrimaryContainer,
        hfAccentColor: hfAccent,
        cardSurfaceColor: Color.alphaBlend(
          colors.primary.withValues(alpha: 0.07),
          baseSurface,
        ),
      ),
    _ => HealthFactorSeverityVisualStyle(
        borderColor: colors.outlineVariant.withValues(alpha: 0.45),
        severityBackground: colors.surfaceContainerHighest,
        severityForeground: colors.onSurfaceVariant,
        hfAccentColor: hfAccent,
        cardSurfaceColor: baseSurface,
      ),
  };
}

Color resolveHealthFactorAccentColor(String? raw, ColorScheme colors) {
  final value = resolveHealthFactorNumber(raw);
  if (value == null) {
    return colors.onSurfaceVariant;
  }
  if (value.isInfinite || value > 2) {
    return colors.primary;
  }
  if (value > 1.5) {
    return colors.tertiary;
  }
  if (value > 1.2) {
    return colors.tertiary.withValues(alpha: 0.95);
  }
  if (value > 1) {
    return colors.error.withValues(alpha: 0.88);
  }
  return colors.error;
}

String _titleCaseSlug(String value) {
  return value
      .split(RegExp(r'[\s_-]+'))
      .where((part) => part.isNotEmpty)
      .map(
        (part) => part.length == 1
            ? part.toUpperCase()
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
