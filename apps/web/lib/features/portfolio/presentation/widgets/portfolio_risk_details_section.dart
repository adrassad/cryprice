import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_formatters.dart';
import 'package:cryprice_frontend/features/portfolio/presentation/widgets/portfolio_health_factor_display.dart';
import 'package:cryprice_frontend/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PortfolioRiskDetailsSection extends StatelessWidget {
  const PortfolioRiskDetailsSection({
    super.key,
    required this.positionsHealth,
  });

  final List<PortfolioPositionHealth> positionsHealth;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.portfolioRiskDetails,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            ..._healthTiles(positionsHealth),
          ],
        ),
      ),
    );
  }

  List<Widget> _healthTiles(List<PortfolioPositionHealth> positionsHealth) {
    final widgets = <Widget>[];
    for (var i = 0; i < positionsHealth.length; i++) {
      if (i > 0) {
        widgets.add(const SizedBox(height: 10));
      }
      widgets.add(
        PortfolioPositionHealthTile(positionHealth: positionsHealth[i]),
      );
    }
    return widgets;
  }
}

class PortfolioPositionHealthTile extends StatelessWidget {
  const PortfolioPositionHealthTile({
    super.key,
    required this.positionHealth,
  });

  final PortfolioPositionHealth positionHealth;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final display = PortfolioHealthFactorDisplay.fromPositionHealth(positionHealth);
    final colors = portfolioHealthFactorColors(theme.colorScheme, display.status);
    final primaryValue = portfolioHealthFactorPrimaryValue(loc, display);
    final statusLabel = portfolioHealthFactorStatusLabel(loc, display);
    final showStatusLabel = shouldShowHealthFactorStatusLabel(
      display,
      statusLabel,
      primaryValue,
    );
    final protocolName = _displayProtocolName(positionHealth);
    final networkName = _displayNetworkName(positionHealth);
    final address = positionHealth.walletAddress.trim();
    final threshold = compactPortfolioThresholdValue(positionHealth.threshold);
    final updatedAt = positionHealth.updatedAt?.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  protocolName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  networkName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    shortenPortfolioAddress(address),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
                if (threshold != null) ...[
                  const SizedBox(height: 8),
                  _MetaField(
                    label: loc.portfolioThreshold,
                    value: threshold,
                  ),
                ],
                if (updatedAt != null && updatedAt.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  PortfolioHealthFactorUpdatedLine(updatedAt: updatedAt),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.$1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        primaryValue,
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
                          statusLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.$2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayProtocolName(PortfolioPositionHealth positionHealth) {
    final name = positionHealth.protocolName.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return positionHealth.protocol;
  }

  String _displayNetworkName(PortfolioPositionHealth positionHealth) {
    final name = positionHealth.networkName.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return positionHealth.network;
  }
}

class PortfolioRiskDetailsUnavailableCard extends StatelessWidget {
  const PortfolioRiskDetailsUnavailableCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          loc.portfolioHealthFactorUnavailable,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MetaField extends StatelessWidget {
  const _MetaField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
