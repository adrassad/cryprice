import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filtered_view.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_overview_display.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_health_factor_badge.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioSummaryCard extends StatelessWidget {
  const PortfolioSummaryCard({
    super.key,
    required this.summary,
    required this.filteredView,
    required this.selectedProtocol,
    required this.selectedWalletId,
    required this.isRefreshing,
  });

  final PortfolioSummary summary;
  final PortfolioFilteredView filteredView;
  final String selectedProtocol;
  final String selectedWalletId;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final overview = PortfolioOverviewDisplay.fromFilters(
      filteredView: filteredView,
      selectedProtocol: selectedProtocol,
      selectedWalletId: selectedWalletId,
      loc: loc,
      summaryUpdatedAtFallback: summary.updatedAt,
    );
    final healthFactor = overview.showHealthFactor ? overview.healthFactor : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 12,
              runSpacing: 12,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 160, maxWidth: 360),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overview.primaryValueLabel(loc),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatPortfolioUsd(
                          overview.primaryValueUsd,
                          unavailableLabel: loc.portfolioValueUnavailable,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (healthFactor != null)
                  PortfolioHealthFactorBadge(healthFactor: healthFactor),
                if (isRefreshing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (overview.scopeHint != null) ...[
              const SizedBox(height: 10),
              Text(
                overview.scopeHint!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (_hasVisibleMetrics(overview)) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (overview.showWalletMetric)
                    _SummaryMetric(
                      label: loc.portfolioWalletValue,
                      value: formatPortfolioUsd(
                        overview.walletValueUsd,
                        unavailableLabel: loc.portfolioValueUnavailable,
                      ),
                    ),
                  if (overview.showSuppliedMetric)
                    _SummaryMetric(
                      label: loc.portfolioSuppliedValue,
                      value: formatPortfolioUsd(
                        overview.suppliedValueUsd,
                        unavailableLabel: loc.portfolioValueUnavailable,
                      ),
                    ),
                  if (overview.showBorrowedMetric)
                    _SummaryMetric(
                      label: loc.portfolioBorrowedValue,
                      value: formatPortfolioUsd(
                        overview.borrowedValueUsd,
                        unavailableLabel: loc.portfolioValueUnavailable,
                      ),
                    ),
                  if (overview.showGrossMetric)
                    _SummaryMetric(
                      label: loc.portfolioGrossValue,
                      value: formatPortfolioUsd(
                        overview.grossValueUsd,
                        unavailableLabel: loc.portfolioValueUnavailable,
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Text(
              '${loc.portfolioLastUpdated}: ${formatPortfolioUpdatedAt(
                summary.updatedAt,
                updatedNeverLabel: loc.portfolioUpdatedNever,
              )}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasVisibleMetrics(PortfolioOverviewDisplay overview) {
    return overview.showWalletMetric ||
        overview.showSuppliedMetric ||
        overview.showBorrowedMetric ||
        overview.showGrossMetric;
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
