import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Current token price with optional stale indicator (CryPrice requirement).
class PortfolioPositionPriceCell extends StatelessWidget {
  const PortfolioPositionPriceCell({
    super.key,
    required this.priceUsd,
    required this.priceStatus,
    this.label,
    this.compact = false,
  });

  final String? priceUsd;
  final PortfolioPriceStatus priceStatus;
  final String? label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final priceText = formatPortfolioUsdForPriceStatus(
      valueUsd: priceUsd,
      priceStatus: priceStatus,
      unavailableLabel: loc.portfolioPriceUnavailable,
      fractionDigits: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        if (label != null) const SizedBox(height: 2),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              priceText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (priceStatus == PortfolioPriceStatus.stale)
              _StaleDataChip(compact: compact),
          ],
        ),
      ],
    );
  }
}

/// USD value for a row; uses [valueUsd] only (not tied to price status).
class PortfolioPositionValueCell extends StatelessWidget {
  const PortfolioPositionValueCell({
    super.key,
    required this.valueUsd,
    this.label,
  });

  final String? valueUsd;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final valueText = formatPortfolioHoldingValueUsd(
      valueUsd,
      unavailableLabel: loc.portfolioValueUnavailable,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        if (label != null) const SizedBox(height: 2),
        Text(
          valueText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Mobile-friendly stacked price + USD value block.
class PortfolioPositionPriceValueRow extends StatelessWidget {
  const PortfolioPositionPriceValueRow({
    super.key,
    required this.priceUsd,
    required this.priceStatus,
    required this.valueUsd,
  });

  final String? priceUsd;
  final PortfolioPriceStatus priceStatus;
  final String? valueUsd;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        PortfolioPositionPriceCell(
          priceUsd: priceUsd,
          priceStatus: priceStatus,
          label: loc.portfolioCurrentPrice,
        ),
        PortfolioPositionValueCell(
          valueUsd: valueUsd,
          label: loc.portfolioUsdValue,
        ),
      ],
    );
  }
}

class _StaleDataChip extends StatelessWidget {
  const _StaleDataChip({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(
        Icons.schedule_outlined,
        size: compact ? 14 : 16,
        color: colorScheme.onTertiaryContainer,
      ),
      label: Text(loc.portfolioStaleData),
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      backgroundColor: colorScheme.tertiaryContainer,
      labelStyle: TextStyle(
        color: colorScheme.onTertiaryContainer,
        fontWeight: FontWeight.w600,
        fontSize: compact ? 11 : null,
      ),
      side: BorderSide.none,
      padding: compact ? EdgeInsets.zero : null,
    );
  }
}
