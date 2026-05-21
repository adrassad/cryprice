import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_health_factor_display.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Compact inline Health Factor row for protocol/network/wallet groups.
class PortfolioGroupHealthFactorRow extends StatelessWidget {
  const PortfolioGroupHealthFactorRow({
    super.key,
    required this.healthFactor,
  });

  final PortfolioHealthFactorDisplay healthFactor;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = portfolioHealthFactorColors(colorScheme, healthFactor.status);
    final value = portfolioHealthFactorPrimaryValue(loc, healthFactor);
    final statusLabel = portfolioHealthFactorStatusLabel(loc, healthFactor);
    final showStatusLabel = shouldShowHealthFactorStatusLabel(
      healthFactor,
      statusLabel,
      value,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          loc.portfolioHealthFactor,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors.$1,
            borderRadius: BorderRadius.circular(999),
            border: _isHighRisk(healthFactor.status)
                ? Border.all(color: colors.$2.withValues(alpha: 0.35))
                : null,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.$2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showStatusLabel)
                Text(
                  statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.$2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        PortfolioHealthFactorUpdatedLine(updatedAt: healthFactor.updatedAt),
      ],
    );
  }

  bool _isHighRisk(PortfolioHealthFactorStatus status) {
    return status == PortfolioHealthFactorStatus.atRisk ||
        status == PortfolioHealthFactorStatus.liquidationRisk;
  }
}
