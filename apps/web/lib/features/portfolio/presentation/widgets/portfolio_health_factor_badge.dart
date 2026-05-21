import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_health_factor_display.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioHealthFactorBadge extends StatelessWidget {
  const PortfolioHealthFactorBadge({
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
    final label = portfolioHealthFactorStatusLabel(loc, healthFactor);
    final showStatusLabel = shouldShowHealthFactorStatusLabel(
      healthFactor,
      label,
      value,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.portfolioHealthFactor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.$2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.$2,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (showStatusLabel) ...[
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: colors.$2),
            ),
          ],
          PortfolioHealthFactorUpdatedLine(updatedAt: healthFactor.updatedAt),
        ],
      ),
    );
  }
}
