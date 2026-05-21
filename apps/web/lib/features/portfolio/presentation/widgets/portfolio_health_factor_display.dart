import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioHealthFactorDisplay {
  const PortfolioHealthFactorDisplay({
    required this.value,
    required this.status,
    required this.statusLabel,
    required this.stale,
    this.updatedAt,
  });

  final String? value;
  final PortfolioHealthFactorStatus status;
  final String? statusLabel;
  final bool stale;
  final String? updatedAt;

  factory PortfolioHealthFactorDisplay.fromPositionHealth(
    PortfolioPositionHealth positionHealth,
  ) {
    return PortfolioHealthFactorDisplay(
      value: positionHealth.healthFactor,
      status: positionHealth.status,
      statusLabel: positionHealth.statusLabel,
      stale: positionHealth.stale,
      updatedAt: positionHealth.updatedAt,
    );
  }
}

/// Primary HF timestamp with portfolio summary as a last-resort fallback.
String? resolveHealthFactorUpdatedAt({
  required String? healthFactorUpdatedAt,
  required String? summaryUpdatedAtFallback,
}) {
  final primary = healthFactorUpdatedAt?.trim();
  if (primary != null && primary.isNotEmpty) {
    return healthFactorUpdatedAt;
  }
  final fallback = summaryUpdatedAtFallback?.trim();
  if (fallback != null && fallback.isNotEmpty) {
    return summaryUpdatedAtFallback;
  }
  return null;
}

bool shouldShowHealthFactorStatusLabel(
  PortfolioHealthFactorDisplay display,
  String statusLabel,
  String primaryValue,
) {
  if (statusLabel == primaryValue) {
    return false;
  }
  if (display.status == PortfolioHealthFactorStatus.stale) {
    return false;
  }
  return true;
}

(Color background, Color foreground) portfolioHealthFactorColors(
  ColorScheme colorScheme,
  PortfolioHealthFactorStatus status,
) {
  return switch (status) {
    PortfolioHealthFactorStatus.safe => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),
    PortfolioHealthFactorStatus.watch ||
    PortfolioHealthFactorStatus.warning ||
    PortfolioHealthFactorStatus.stale => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
      ),
    PortfolioHealthFactorStatus.atRisk ||
    PortfolioHealthFactorStatus.liquidationRisk => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
    PortfolioHealthFactorStatus.none ||
    PortfolioHealthFactorStatus.noDebt ||
    PortfolioHealthFactorStatus.missing ||
    PortfolioHealthFactorStatus.unknown => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
      ),
  };
}

String portfolioHealthFactorPrimaryValue(
  AppLocalizations loc,
  PortfolioHealthFactorDisplay display,
) {
  return switch (display.status) {
    PortfolioHealthFactorStatus.none ||
    PortfolioHealthFactorStatus.noDebt => loc.portfolioNoBorrowRisk,
    PortfolioHealthFactorStatus.missing => loc.portfolioHealthFactorUnavailable,
    _ =>
      compactPortfolioDecimalValue(display.value) ??
          loc.portfolioHealthFactorUnavailable,
  };
}

String portfolioHealthFactorStatusLabel(
  AppLocalizations loc,
  PortfolioHealthFactorDisplay display,
) {
  final backendLabel = display.statusLabel?.trim();
  if (backendLabel != null && backendLabel.isNotEmpty) {
    return backendLabel;
  }

  return switch (display.status) {
    PortfolioHealthFactorStatus.none ||
    PortfolioHealthFactorStatus.noDebt => loc.portfolioNoBorrowRisk,
    PortfolioHealthFactorStatus.safe => loc.portfolioSafe,
    PortfolioHealthFactorStatus.watch => loc.portfolioWatch,
    PortfolioHealthFactorStatus.warning => loc.portfolioWarning,
    PortfolioHealthFactorStatus.atRisk => loc.portfolioAtRisk,
    PortfolioHealthFactorStatus.liquidationRisk => loc.portfolioLiquidationRisk,
    PortfolioHealthFactorStatus.missing => loc.portfolioHealthFactorUnavailable,
    PortfolioHealthFactorStatus.stale => loc.portfolioStaleData,
    PortfolioHealthFactorStatus.unknown => loc.portfolioUnknown,
  };
}

String? compactPortfolioThresholdValue(String? value) {
  return compactPortfolioDecimalValue(value);
}

/// Compact Health Factor freshness line (no stale badge).
class PortfolioHealthFactorUpdatedLine extends StatelessWidget {
  const PortfolioHealthFactorUpdatedLine({
    super.key,
    required this.updatedAt,
  });

  final String? updatedAt;

  @override
  Widget build(BuildContext context) {
    final trimmed = updatedAt?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return const SizedBox.shrink();
    }

    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final formatted = formatPortfolioUpdatedAt(
      trimmed,
      updatedNeverLabel: loc.portfolioUpdatedNever,
    );

    return Text(
      loc.portfolioHealthFactorUpdatedAt(formatted),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 11,
      ),
    );
  }
}
