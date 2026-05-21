import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/portfolio_filter.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/utils/portfolio_protocol_summary_options.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_health_factor_display.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioProtocolSummaryCard extends StatelessWidget {
  const PortfolioProtocolSummaryCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
    this.valueLabel,
  });

  final PortfolioProtocolStripOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant.withValues(alpha: 0.6);
    final backgroundColor = isSelected
        ? colorScheme.primaryContainer.withValues(alpha: 0.35)
        : colorScheme.surfaceContainerLow;

    final healthStatus = option.healthFactorStatus;
    final showHealthIndicator =
        option.protocolId != PortfolioFilter.walletProtocol &&
            healthStatus != null &&
            healthStatus != PortfolioHealthFactorStatus.none;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 168,
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                option.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                valueLabel ?? loc.portfolioNetValue,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatPortfolioUsd(
                  option.valueUsd,
                  unavailableLabel: loc.portfolioValueUnavailable,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showHealthIndicator) ...[
                const SizedBox(height: 8),
                _ProtocolHealthIndicator(
                  status: healthStatus,
                  statusLabel: option.healthFactorStatusLabel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProtocolHealthIndicator extends StatelessWidget {
  const _ProtocolHealthIndicator({
    required this.status,
    required this.statusLabel,
  });

  final PortfolioHealthFactorStatus status;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final display = PortfolioHealthFactorDisplay(
      value: null,
      status: status,
      statusLabel: statusLabel,
      stale: status == PortfolioHealthFactorStatus.stale,
    );
    final colors = portfolioHealthFactorColors(theme.colorScheme, status);
    final label = portfolioHealthFactorStatusLabel(loc, display);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.$2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
