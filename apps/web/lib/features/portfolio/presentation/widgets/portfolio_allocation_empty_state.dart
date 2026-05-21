import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_allocation_selection.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioAllocationEmptyState extends StatelessWidget {
  const PortfolioAllocationEmptyState({
    super.key,
    required this.mode,
  });

  final PortfolioAllocationMode mode;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final message = switch (mode) {
      PortfolioAllocationMode.assets => loc.portfolioNoAllocationData,
      PortfolioAllocationMode.debts => loc.portfolioNoDebtPositions,
      PortfolioAllocationMode.protocols => loc.portfolioNoProtocolAllocation,
      PortfolioAllocationMode.networks => loc.portfolioNoNetworkAllocation,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
