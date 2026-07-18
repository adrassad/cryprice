import 'package:cryprice_frontend/features/health_factor/domain/entities/health_factor_warning.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Presentation-only colors for calculator [riskLevel] strings from backend.
(Color background, Color foreground) healthFactorCalcRiskColors(
  ColorScheme colorScheme,
  String riskLevel,
) {
  return switch (riskLevel.trim().toLowerCase()) {
    'no_debt' || 'safer' || 'safe' => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),
    'moderate' => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
    'watch' || 'warning' => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
      ),
    'high' => (
        colorScheme.errorContainer.withValues(alpha: 0.72),
        colorScheme.onErrorContainer,
      ),
    'critical' || 'liquidation' || 'liquidation_risk' || 'at_risk' => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
    _ => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
      ),
  };
}

String healthFactorCalcRiskLabel(AppLocalizations loc, String riskLevel) {
  return switch (riskLevel.trim().toLowerCase()) {
    'no_debt' => loc.hfCalcRiskNoDebt,
    'safer' => loc.hfCalcRiskSafer,
    'safe' => loc.hfCalcRiskSafer,
    'moderate' => loc.hfCalcRiskModerate,
    'watch' => loc.hfCalcRiskWarning,
    'warning' => loc.hfCalcRiskWarning,
    'high' => loc.hfCalcRiskHigh,
    'critical' => loc.hfCalcRiskCritical,
    'liquidation' || 'liquidation_risk' => loc.hfCalcRiskLiquidation,
    'at_risk' => loc.hfCalcRiskHigh,
    _ => riskLevel.trim().isEmpty ? loc.hfCalcRiskUnknown : riskLevel.trim(),
  };
}

String healthFactorCalcFormatUsd(String? value, {required String unavailable}) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return unavailable;
  }
  return '\$$trimmed';
}

/// Localized warning text; falls back to backend message when code is unknown.
String healthFactorCalcWarningMessage(
  AppLocalizations loc,
  HealthFactorWarning warning,
) {
  final code = warning.code?.trim().toUpperCase();
  if (code != null && code.isNotEmpty) {
    switch (code) {
      case 'CUSTOM_PRICE_USED':
        return loc.hfCalcCustomPriceUsed;
      case 'CUSTOM_PRICE_DIFFERS_FROM_MARKET':
        return loc.hfCalcCustomPriceDiffers;
      default:
        break;
    }
  }
  final message = warning.message?.trim();
  if (message != null && message.isNotEmpty) {
    return message;
  }
  final raw = warning.raw?.trim();
  if (raw != null && raw.isNotEmpty) {
    return raw;
  }
  return warning.code?.trim() ?? '';
}

bool healthFactorCalcIsCustomPriceSource(String? priceSource) {
  return priceSource?.trim().toLowerCase() == 'custom';
}

String healthFactorCalcPriceSourceBadgeLabel(
  AppLocalizations loc,
  String? priceSource,
) {
  if (healthFactorCalcIsCustomPriceSource(priceSource)) {
    final label = loc.hfCalcCustomPrice;
    final paren = label.indexOf('(');
    if (paren > 0) {
      return label.substring(0, paren).trim();
    }
    return label;
  }
  return loc.hfCalcMarketPrice;
}
